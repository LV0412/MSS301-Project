from sqlalchemy.orm import Session, sessionmaker

from database.database import get_engine


_session_factory: sessionmaker[Session] | None = None


def get_session_local() -> sessionmaker[Session]:
    global _session_factory
    if _session_factory is None:
        _session_factory = sessionmaker(autocommit=False, autoflush=False, bind=get_engine())
    return _session_factory


def SessionLocal() -> Session:
    return get_session_local()()
