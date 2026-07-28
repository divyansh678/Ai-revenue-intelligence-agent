import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from urllib.parse import quote_plus

load_dotenv()


def get_engine():
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT", "3306")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    database = os.getenv("DB_NAME")

    missing = [
        name for name, value in {
            "DB_HOST": host,
            "DB_USER": user,
            "DB_PASSWORD": password,
            "DB_NAME": database,
        }.items()
        if not value
    ]

    if missing:
        raise ValueError(
            "Missing environment variables: " + ", ".join(missing)
        )

    encoded_password = quote_plus(password)

    url = (
        f"mysql+mysqlconnector://{user}:{encoded_password}"
        f"@{host}:{port}/{database}"
    )

    return create_engine(
        url,
        pool_pre_ping=True,
        pool_recycle=1800,
        connect_args={
            "ssl_disabled": False,
            "ssl_ca": "ca.pem",
        },
    )
