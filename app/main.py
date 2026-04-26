import pathlib
from datetime import datetime
from typing import Any

import functions_framework
import google_crc32c
import pandas as pd
from cloudevents.http import CloudEvent
from dateutil import tz
from dateutil.relativedelta import relativedelta
from google.cloud import bigquery, secretmanager
from loguru import logger
from slack_sdk.webhook import WebhookClient
from slack_sdk.webhook.webhook_response import WebhookResponse


def calc_gcp_cost(
    billing_account_id: str, start_date_jst: str, end_date_jst: str
) -> tuple[pd.DataFrame, Any]:
    """Calculate gcp const
    Args:
        billing_account_id (str): billing account id
        start_date_jst (str): start date (jst)
        end_date_jst (str): end date (jst)

    Returns:
        tuple[pd.DataFrame, Any]: gcp cost dataframe and cost of query
    """
    if not isinstance(billing_account_id, str) or not billing_account_id:
        raise ValueError("Invalid billing_account_id provided.")
    billing_account_id = billing_account_id.replace("-", "_")

    sql_path = pathlib.Path("./sql/calc_gcp_cost.sql")
    with open(sql_path, "r") as fo:
        query = fo.read()
        query = query.format(
            billing_account_id=billing_account_id,
            start_date_jst=start_date_jst,
            end_date_jst=end_date_jst,
        )
    bq_client = bigquery.Client(project="haru256-billing-report")
    query_job = bq_client.query(query)
    df: pd.DataFrame = query_job.result().to_dataframe()
    processed_gib_bytes = query_job.total_bytes_processed / 1073741824
    return df, processed_gib_bytes


def fetch_secret_version(project_id: str, secret_id: str, version_id: str) -> str:
    """
    Access the payload for the given secret version if one exists. The version
    can be a version number as a string (e.g. "5") or an alias (e.g. "latest").
    Args:
        project_id (str): project
        secret_id (str): secret_id
        version_id (str): a version number as a string (e.g. "5") or
            an alias (e.g. "latest").
    Returns:
        str: secret value
    """
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(request={"name": name})

    # Verify payload checksum.
    crc32c = google_crc32c.Checksum()
    crc32c.update(response.payload.data)
    if response.payload.data_crc32c != int(crc32c.hexdigest(), 16):
        raise ValueError("Data corruption detected.")

    payload = response.payload.data.decode("UTF-8")

    return payload


def build_message(
    billing_account_id: str,
    start_date_jst: str,
    end_date_jst: str,
    cost_df: pd.DataFrame,
    processed_gib_bytes: int,
) -> list[dict[str, Any]]:
    """Build message that is sent to slack

    Args:
        billing_account_id (str): billing account id
        start_date_jst (str): start date (jst)
        end_date_jst (str): end date (jst)
        cost_df (pd.DataFrame): gcp cost dataframe
        processed_gib_bytes (int): cost of calculating query

    Returns:
        list[dict[str, Any]]: slack message blocks
    """
    if len(cost_df) == 0:
        cost_text = "No Billing Cost."
    else:
        cost_text = "\n".join(
            [f"• {row.service_name}: {row.total:.2f} yen" for _, row in cost_df.iterrows()]
        )
    billing_report_url = f"https://console.cloud.google.com/billing/{billing_account_id}"
    blocks = [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"`Daily Report` (2 week cost from *{start_date_jst}* to *{end_date_jst}*) "
                ":money_with_wings:",
            },
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"Billing Cost from BigQuery (processed GiB: {processed_gib_bytes:.2f})",
            },
        },
        {"type": "section", "text": {"type": "mrkdwn", "text": cost_text}},
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"More Info:\n• <{billing_report_url}|Billing Report>\n",
            },
        },
    ]

    return blocks


def report_gcp_cost_to_slack() -> WebhookResponse:
    """Reporting GCP cost to the Slack channel
    Returns:
        WebhookResponse: the response from the slack webhook
    """
    logger.info("Fetching Slack webhook URL and billing account ID from Secret Manager")
    slack_webhook_url = fetch_secret_version(
        "haru256-billing-report", "SLACK_WEBHOOK_URL", "latest"
    )
    billing_account_id = fetch_secret_version(
        "haru256-billing-report", "BILLING_ACCOUNT_ID", "latest"
    )

    webhook = WebhookClient(slack_webhook_url)

    end_datetime_jst = datetime.now(tz=tz.gettz("Asia/Tokyo"))
    end_date_jst = end_datetime_jst.strftime("%Y-%m-%d")
    start_datetime_jst = end_datetime_jst - relativedelta(weeks=2)
    start_date_jst = start_datetime_jst.strftime("%Y-%m-%d")

    logger.info(
        "Querying billing data from BigQuery: start_date_jst={}, end_date_jst={}",
        start_date_jst,
        end_date_jst,
    )
    cost_df, processed_gib_bytes = calc_gcp_cost(billing_account_id, start_date_jst, end_date_jst)

    logger.info("Sending billing report to Slack")
    blocks = build_message(
        billing_account_id, start_date_jst, end_date_jst, cost_df, processed_gib_bytes
    )
    response = webhook.send(
        text="Billing Report",
        blocks=blocks,
    )
    return response


@functions_framework.cloud_event
def main(cloud_event: CloudEvent) -> None:
    """Endpoint for google cloud function.
    Args:
        cloud_event (CloudEvent): Pub/Sub CloudEvent.
    """
    logger.info(
        "Received CloudEvent: id={}, type={}, source={}",
        cloud_event.get("id"),
        cloud_event.get("type"),
        cloud_event.get("source"),
    )
    response = report_gcp_cost_to_slack()
    if response.status_code != 200:
        raise RuntimeError(
            "Slack webhook returned non-200 status: "
            f"status_code={response.status_code}, body={response.body!r}"
        )
