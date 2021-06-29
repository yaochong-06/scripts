
import cx_Oracle
def get_oracle_result():
    try:
        connection = cx_Oracle.connect('scott', 'tiger', '127.0.0.1:1521/yao')
        cursor = connection.cursor()
        for i in range(1, 10000000):
 
            sql_text = 'delete from emp1 where deptno = :dno' 
            cursor.execute(sql_text, {'dno': i})
            connection.commit()
            print(f"current execution....")
    except Exception as re:
        print(re)
    finally:
        print("end")
        cursor.close()
        connection.close()
get_oracle_result()
