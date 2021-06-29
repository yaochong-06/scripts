import cx_Oracle
def get_oracle_result():
    try:
        for i in range(1, 10000000):
            connection = cx_Oracle.connect('scott', 'tiger', '127.0.0.1:1521/yao')
            cursor = connection.cursor()
            sql_text = 'delete from emp1 where deptno = :dno'
            cursor.execute(sql_text, {'dno': i})
            connection.commit()
            print(f"current execution....")
            cursor.close()
            connection.close()
    except Exception as re:
        print(re)
    finally:
        print("end")
get_oracle_result()
