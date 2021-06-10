
import cx_Oracle
def get_oracle_result():
    try:
        for i in range(1, 10000000):
            connection = cx_Oracle.connect('scott', 'tiger', '127.0.0.1:1521/prod1')
            cursor = connection.cursor()
            cursor.prepare("""insert into emp1 values(:eno,'haha','JOB',1,sysdate,2,3,4)""")
            cursor.execute(None, {'eno': i})
            cursor.prepare('delete from emp1 where DEPTNO=:dno')
            cursor.execute(None, {'dno': i})
            connection.commit()
            print(f"current execution....")
            cursor.close()
            connection.close()
    except Exception as re:
        print(re)
    finally:
        print("end")
get_oracle_result()
