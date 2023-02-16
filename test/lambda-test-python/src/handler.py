import json

import pyodbc
import json


def lambda_handler(event, context):
    print(f"LAMBDA EVENT: {json.dumps(event)}")

    conn = pyodbc.connect(
        'Driver={ODBC Driver 17 for SQL Server};Server=database-2.cgu1i6innl6a.us-east-1.rds.amazonaws.com,1433;Database=master;Uid=admin;Pwd=test12345;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;')
    cursor = conn.cursor()

    print("BEFORE USER CREATION")
    list_all_users(cursor=cursor)

    create_users_sql = f"CREATE LOGIN {event.get('username')} WITH PASSWORD = '{event.get('password')}';"
    cursor.execute(create_users_sql)
    conn.commit()

    print("AFTER USER CREATION")
    list_all_users(cursor=cursor)


def list_all_users(cursor):
    list_users_sql = """select sp.name as login,
       sp.type_desc as login_type,
       sl.password_hash,
       sp.create_date,
       sp.modify_date,
       case when sp.is_disabled = 1 then 'Disabled'
            else 'Enabled' end as status
from sys.server_principals sp
left join sys.sql_logins sl
          on sp.principal_id = sl.principal_id
where sp.type not in ('G', 'R')
order by sp.name;"""
    print(f"sql query: {list_users_sql}")
    cursor.execute(list_users_sql)

    for row in cursor:
        print(row)
