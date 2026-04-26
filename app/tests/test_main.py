import os
from types import SimpleNamespace
from typing import Any

import pytest
from cloudevents.http import CloudEvent
from pytest_mock import MockerFixture

from main import main


@pytest.fixture
def pubsub_cloudevent() -> CloudEvent:
    attributes = {
        "id": "local-test-1",
        "source": "//pubsub.googleapis.com/projects/local-project/topics/local-topic",
        "type": "google.cloud.pubsub.topic.v1.messagePublished",
        "specversion": "1.0",
        "datacontenttype": "application/json",
    }
    data = {
        "message": {
            "data": "e30=",
            "messageId": "1",
        },
        "subscription": "local",
    }

    return CloudEvent(attributes, data)


def test_main_calls_reporter_with_pubsub_cloudevent(
    mocker: MockerFixture, pubsub_cloudevent: CloudEvent
) -> None:
    def report_gcp_cost_to_slack() -> Any:
        return SimpleNamespace(status_code=200, body="ok")

    report_mock = mocker.patch("main.report_gcp_cost_to_slack", side_effect=report_gcp_cost_to_slack)

    main(pubsub_cloudevent)

    report_mock.assert_called_once_with()


def test_main_raises_with_slack_response_details(
    mocker: MockerFixture, pubsub_cloudevent: CloudEvent
) -> None:
    def report_gcp_cost_to_slack() -> Any:
        return SimpleNamespace(status_code=500, body="invalid webhook")

    mocker.patch("main.report_gcp_cost_to_slack", side_effect=report_gcp_cost_to_slack)

    with pytest.raises(
        RuntimeError,
        match="Slack webhook returned non-200 status: status_code=500, body='invalid webhook'",
    ):
        main(pubsub_cloudevent)


@pytest.mark.live
@pytest.mark.skipif(
    os.getenv("RUN_LIVE_GCP_TESTS") != "1",
    reason="set RUN_LIVE_GCP_TESTS=1 to run the live GCP/Slack smoke test",
)
def test_main_with_pubsub_cloudevent_live(pubsub_cloudevent: CloudEvent) -> None:
    main(pubsub_cloudevent)
