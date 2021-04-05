def check_keys_in_dict(dict_: dict, fields: list[str]) -> bool:
    for field in fields:
        if field not in dict_:
            return False
    return True