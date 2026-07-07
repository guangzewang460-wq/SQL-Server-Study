

-------------------  1. PRINT和SELECT的区别  --------------------

PRINT GETDATE(), '测试'; -- 语法错误

SELECT GETDATE(), '测试';
PRINT LEN('Hello'); -- 先计算LEN=5，自动转字符串打印在消息栏
PRINT GETDATE();

-- 返回表格，一列一行，值为5
SELECT LEN('Hello');

-- 可以多字段一起输出
SELECT GETDATE(), LEN('test'), IIF(1>0,'是','否');

-- 可放到子查询、赋值
DECLARE @num INT = (SELECT CAST('123' AS INT));

PRINT LEN('Hello'); -- 先计算LEN=5，自动转字符串打印在消息栏
PRINT GETDATE();






-------------------  2.查询案例   --------------------
-- 查询要求：显示完整姓名（拼接）、入职年限、格式化电话号码（NULL显示"未录入"）
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    HireDate DATETIME,
    Phone VARCHAR(20)
);

INSERT INTO Employees VALUES
(1, '张', '三', '2020-05-15', '13800138000'),
(2, 'Li', 'Si', '2021-08-20', NULL),
(3, '王', '五', '2019-03-10', '13900139000');

select FirstName+LastName as 姓名 ,DATEDIFF(YEAR, HireDate, GETDATE()) as 入职年限, ISNULL(Phone,'未录入')  from Employees



-------------------  3.标量函数  --------------------
-- 输入出生日期，返回年龄
create function fn_CalculateAge
(
    @BirthDate Date
)
returns int
as0

begin
    declare @Age int;
    set @Age = DATEDIFF(YEAR,@BirthDate,GETDATE()) - 
               CASE
                   WHEN MONTH(@BirthDate) > MONTH(GETDATE())
                        OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
                   THEN 1 	
                   ELSE 0
               END;
     return @Age;
end

select EmployeeName,dbo.fn_CalculateAge(BirthDate) as Age from Employees


