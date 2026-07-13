# SQL Server 从入门到精通 - 实战教程

> 本教程专为需要快速掌握企业级 SQL Server 开发的工程师设计，涵盖从基础到高级存储过程、复杂关联查询等核心技能。

---

## 目录

1. [第一章：SQL Server 基础与环境](#第一章sql-server-基础与环境)
2. [第二章：数据类型与表设计](#第二章数据类型与表设计)
3. [第三章：基础查询与条件过滤](#第三章基础查询与条件过滤)
4. [第四章：多表关联查询（核心）](#第四章多表关联查询核心)
5. [第五章：子查询与公用表表达式](#第五章子查询与公用表表达式)
6. [第六章：聚合函数与分组统计](#第六章聚合函数与分组统计)
7. [第七章：数据操作语言（DML）](#第七章数据操作语言dml)
8. [第八章：索引设计与优化基础](#第八章索引设计与优化基础)
9. [第九章：视图（View）](#第九章视图view)
10. [第十章：存储过程（核心）](#第十章存储过程核心)
11. [第十一章：函数与触发器](#第十一章函数与触发器)
12. [第十二章：事务与并发控制](#第十二章事务与并发控制)
13. [第十三章：综合实战案例](#第十三章综合实战案例)

---

## 第一章：SQL Server 基础与环境

### 1.1 连接与基本操作

```sql
-- 查看所有数据库
SELECT name FROM sys.databases;

-- 切换数据库
USE [DatabaseName];

-- 查看当前数据库的所有表
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';


-- 查看表结构
EXEC sp_help 'TableName';

-- 或者
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TableName';
```

### 1.2 SQL Server 特有函数

```sql
-- 获取当前时间
SELECT GETDATE();                    -- 2024-01-15 14:30:25.123
SELECT GETUTCDATE();                 -- UTC 时间
SELECT SYSDATETIME();                -- 更高精度

-- 字符串函数
SELECT LEN('Hello');                 -- 5，返回字符串长度
SELECT DATALENGTH('Hello');          -- 5，返回字节数
SELECT LEFT('Hello', 3);             -- Hel
SELECT RIGHT('Hello', 3);            -- llo
SELECT SUBSTRING('Hello World', 7, 5); -- World
SELECT REPLACE('Hello World', 'World', 'SQL'); -- Hello SQL
SELECT CHARINDEX('World', 'Hello World'); -- 7，查找子串位置

-- 类型转换
SELECT CAST('123' AS INT);
-- 等价于：
SELECT CONVERT(INT, '123');

SELECT CONVERT(VARCHAR, GETDATE(), 120); -- 2024-01-15 14:30:25
SELECT CONVERT(VARCHAR, GETDATE(), 111); -- 2024/01/15

-- 解释：
-- CONVERT(目标类型, 日期值, 格式码)
-- 120	yyyy-MM-dd HH:mm:ss	2026-07-06 16:20:10
-- 111	yyyy/MM/dd	2026/07/06
-- 101	mm/dd/yyyy	07/06/2026
-- 102	yyyy.mm.dd	2026.07.06
-- 108	HH:mm:ss	16:20:10


-- 空值处理
SELECT ISNULL(NULL, '默认值');        -- 默认值
SELECT COALESCE(NULL, NULL, '第一个非空值'); -- 第一个非空值，从左往右查找，返回第一个不为 NULL的值；全部为 NULL 才返回 NULL
SELECT NULLIF(10, 10);               -- NULL，相等返回NULL，两个值相等 → 返回NULL；不相等 → 返回第一个值

-- 判断函数
SELECT IIF(1 > 0, '真', '假');       -- 真


-- 时间计算
-- 相差天数
SELECT DATEDIFF(day, '2026-01-01', GETDATE());

-- 相差月份
SELECT DATEDIFF(month, '2026-01-01', '2026-07-07'); -- 6

-- 相差年份
SELECT DATEDIFF(year, '2020-05-01', '2026-03-01'); -- 6

-- 相差小时
SELECT DATEDIFF(hour, '2026-07-07 08:00:00', '2026-07-07 15:30:00'); --7
```

### 本章案例

**案例 1.1：员工信息格式化查询**

假设有员工表 `Employees`：
```sql
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
```

查询要求：显示完整姓名（拼接）、入职年限、格式化电话号码（NULL显示"未录入"）

```sql
SELECT
    EmployeeID,
    FirstName + LastName AS FullName,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService,
    ISNULL(Phone, '未录入') AS ContactPhone
FROM Employees;
```

---

## 第二章：数据类型与表设计

### 2.1 常用数据类型

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| `INT` | 4字节整数 | ID、数量、状态码 |
| `BIGINT` | 8字节大整数 | 大数据量ID、时间戳 |
| `DECIMAL(p,s)` / `NUMERIC(p,s)` | 精确小数 | 金额、汇率 |
| `FLOAT` / `REAL` | 浮点数 | 科学计算（不推荐用于金额） |
| `VARCHAR(n)` | 变长字符串 | 姓名、地址、描述 |
| `NVARCHAR(n)` | Unicode变长字符串 | 中文、多语言内容 |
| `CHAR(n)` | 定长字符串 | 固定长度编码（如身份证号） |
| `DATETIME` | 日期时间 | 创建时间、更新时间 |
| `DATETIME2` | 更高精度日期时间 | 需要毫秒级以上精度 |
| `DATE` | 仅日期 | 生日、生效日期 |
| `BIT` | 0/1/NULL | 布尔标志（是否启用） |
| `TEXT` / `NTEXT` | 大文本（已弃用） | **改用 VARCHAR(MAX)** |
| `VARBINARY(MAX)` | 二进制大对象 | 文件存储 |
| `UNIQUEIDENTIFIER` | GUID | 分布式系统ID |

### 2.2 表设计规范（企业级）

```sql
-- 典型企业表结构示例
CREATE TABLE Products (
    -- 主键：建议使用自增ID或GUID
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    -- ProductID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY, -- 替代方案

    -- 业务字段
    ProductCode VARCHAR(50) NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    Description NVARCHAR(MAX) NULL,

    -- 审计字段（几乎每个表都要有）
    CreatedBy VARCHAR(50) NOT NULL DEFAULT SYSTEM_USER,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedBy VARCHAR(50) NULL,
    ModifiedDate DATETIME NULL,

    -- 约束
    CONSTRAINT UQ_ProductCode UNIQUE(ProductCode),
    CONSTRAINT CK_UnitPrice CHECK(UnitPrice >= 0),
    CONSTRAINT FK_Category FOREIGN KEY(CategoryID)
        REFERENCES Categories(CategoryID)
);

-- 创建索引
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_Products_IsActive ON Products(IsActive) INCLUDE(ProductName, UnitPrice);
```

### 2.3 临时表与表变量

```sql
-- 本地临时表（仅当前会话可见）
CREATE TABLE #TempEmployees (
    ID INT,
    Name NVARCHAR(100)
);

-- 全局临时表（所有会话可见，需 ## 前缀）
CREATE TABLE ##GlobalTemp (
    ID INT
);

-- 表变量（存储过程内使用，无日志，适合小数据量）
DECLARE @TableVar TABLE (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

INSERT INTO @TableVar VALUES (1, '测试');
SELECT * FROM @TableVar;
```

### 本章案例

**案例 2.1：电商订单表设计**

```sql
-- 订单主表
CREATE TABLE Orders (
    OrderID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderNo VARCHAR(50) NOT NULL,                    -- 业务单号
    CustomerID INT NOT NULL,
    OrderStatus TINYINT NOT NULL DEFAULT 0,          -- 0:待支付 1:已支付 2:已发货 3:已完成 4:已取消
    OrderAmount DECIMAL(18,2) NOT NULL DEFAULT 0,    -- 订单金额
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0, -- 优惠金额
    PayableAmount AS (OrderAmount - DiscountAmount), -- 计算列
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaidDate DATETIME NULL,
    ShippedDate DATETIME NULL,
    Remark NVARCHAR(500) NULL,
    CreatedBy VARCHAR(50) NOT NULL DEFAULT SYSTEM_USER,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT UQ_OrderNo UNIQUE(OrderNo),
    CONSTRAINT CK_OrderStatus CHECK(OrderStatus BETWEEN 0 AND 4),
    CONSTRAINT CK_OrderAmount CHECK(OrderAmount >= 0)
);

-- 订单明细表
CREATE TABLE OrderDetails (
    DetailID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID BIGINT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(18,2) NOT NULL,
    Subtotal AS (Quantity * UnitPrice),
    CONSTRAINT FK_OrderDetails_Order FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT CK_Quantity CHECK(Quantity > 0)
);
```

---

## 第三章：基础查询与条件过滤

### 3.1 SELECT 基础

```sql
-- 基本查询
SELECT * FROM Products;

-- 指定列
SELECT ProductID, ProductName, UnitPrice FROM Products;

-- 别名
SELECT
    ProductID AS 产品ID,
    ProductName AS 产品名称,
    UnitPrice AS 单价
FROM Products;

-- 去重
SELECT DISTINCT CategoryID FROM Products;

-- 限制行数
SELECT TOP 10 * FROM Products;
SELECT TOP 10 PERCENT * FROM Products;
SELECT * FROM Products ORDER BY UnitPrice OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; -- SQL Server 2012+

-- 排序
SELECT * FROM Products ORDER BY UnitPrice ASC;  -- 升序（默认）
SELECT * FROM Products ORDER BY UnitPrice DESC; -- 降序
SELECT * FROM Products ORDER BY CategoryID ASC, UnitPrice DESC; -- 多列排序
```

### 3.2 WHERE 条件过滤

```sql
-- 比较运算符
SELECT * FROM Products WHERE UnitPrice > 100;
SELECT * FROM Products WHERE UnitPrice BETWEEN 50 AND 100;
SELECT * FROM Products WHERE CategoryID IN (1, 2, 3);
SELECT * FROM Products WHERE ProductName LIKE '%手机%';  -- 包含"手机"
SELECT * FROM Products WHERE ProductName LIKE '苹果_';   -- 苹果+一个字符
SELECT * FROM Products WHERE ProductName LIKE '[ABC]%'; -- A/B/C开头

-- 逻辑运算符
SELECT * FROM Products WHERE UnitPrice > 100 AND CategoryID = 1;
SELECT * FROM Products WHERE UnitPrice > 100 OR CategoryID = 1;
SELECT * FROM Products WHERE NOT (CategoryID = 1);

-- 空值判断（重要：不能用 = NULL）
SELECT * FROM Products WHERE Description IS NULL;
SELECT * FROM Products WHERE Description IS NOT NULL;

-- EXISTS
SELECT * FROM Categories c
WHERE EXISTS (SELECT 1 FROM Products p WHERE p.CategoryID = c.CategoryID);
```

### 3.3 字符串条件处理

```sql
-- 企业常见场景：模糊搜索优化
DECLARE @Keyword NVARCHAR(100) = '%手机%';
SELECT * FROM Products WHERE ProductName LIKE @Keyword;

-- 多关键词搜索（使用 OR）
SELECT * FROM Products
WHERE ProductName LIKE '%苹果%'
   OR ProductName LIKE '%华为%'
   OR ProductName LIKE '%小米%';

-- 去除空格后比较
SELECT * FROM Products WHERE LTRIM(RTRIM(ProductName)) = 'iPhone';
SELECT * FROM Products WHERE TRIM(ProductName) = 'iPhone';

-- 大小写不敏感（默认）/敏感
SELECT * FROM Products WHERE ProductName COLLATE Chinese_PRC_CS_AS = 'IPHONE'; -- 敏感
-- 默认不区分，三条全部查出
WHERE ProductName = 'IPHONE';
```

### 本章案例

**案例 3.1：综合查询练习**

基于以下表结构：
```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName NVARCHAR(50),
    DepartmentID INT,
    Salary DECIMAL(18,2),
    HireDate DATE,
    IsActive BIT DEFAULT 1
);

INSERT INTO Employees VALUES
(1, '张三', 1, 8000, '2020-01-15', 1),
(2, '李四', 1, 12000, '2019-06-20', 1),
(3, '王五', 2, 15000, '2018-03-10', 1),
(4, '赵六', 2, 6000, '2022-08-05', 0),
(5, '孙七', 3, 20000, '2017-11-30', 1);
```

查询要求：
```sql
-- 1. 查询薪资在8000到15000之间的在职员工
SELECT * FROM Employees
WHERE Salary BETWEEN 8000 AND 15000 AND IsActive = 1;

-- 2. 查询姓名中包含"张"或"王"的员工
SELECT * FROM Employees
WHERE EmployeeName LIKE '%张%' OR EmployeeName LIKE '%王%';

-- 3. 查询入职超过3年的员工，按薪资降序
SELECT *, DATEDIFF(YEAR, HireDate, GETDATE()) AS WorkYears
FROM Employees
WHERE DATEDIFF(YEAR, HireDate, GETDATE()) > 3
ORDER BY Salary DESC;

-- 4. 查询薪资最高的前3名员工
SELECT TOP 3 * FROM Employees ORDER BY Salary DESC;
```

---

## 第四章：多表关联查询（核心）

### 4.1 JOIN 类型详解

```sql
-- 内连接：只返回匹配的行（最常用）
SELECT o.OrderID, c.CustomerName, o.OrderAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID;

-- 左连接：返回左表所有行，右表不匹配则为NULL
SELECT c.CustomerName, o.OrderID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;
-- 用途：查找没有订单的客户
-- WHERE o.OrderID IS NULL

-- 右连接：返回右表所有行（较少使用，通常交换表位置用LEFT JOIN）
SELECT c.CustomerName, o.OrderID
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 全外连接：返回两边所有行，不匹配则为NULL
SELECT c.CustomerName, o.OrderID
FROM Customers c
FULL OUTER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 交叉连接：笛卡尔积（慎用！）
SELECT * FROM TableA CROSS JOIN TableB;
```

### 4.2 多表关联（实际工作最常见）

```sql
-- 3表关联：订单-客户-产品
SELECT
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS SubTotal
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;

-- 4表关联：员工-部门-职位-上级
SELECT
    e.EmployeeName,
    d.DepartmentName,
    p.PositionName,
    ISNULL(m.EmployeeName, '无') AS ManagerName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
INNER JOIN Positions p ON e.PositionID = p.PositionID
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID; -- 自连接
```

### 4.3 复杂关联场景

```sql
-- 场景1：查找有订单但没付款的客户
SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.PaidDate IS NULL;

-- 场景2：查找购买过指定产品的所有客户
SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE od.ProductID = 1001;

-- 场景3：统计每个客户的订单数量和总金额（聚合+关联）
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(o.OrderAmount), 0) AS TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;

-- 场景4：查找同时购买了产品A和产品B的客户（交集）
SELECT c.CustomerID, c.CustomerName
FROM Customers c
WHERE c.CustomerID IN (
    SELECT o.CustomerID FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE od.ProductID = 1001
)
AND c.CustomerID IN (
    SELECT o.CustomerID FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE od.ProductID = 1002
);
```

### 本章案例

**案例 4.1：综合多表查询**

假设有以下表结构：
```sql
-- 客户表
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    City NVARCHAR(50),
    RegisterDate DATE
);

-- 订单表
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Status VARCHAR(20) -- 'Pending', 'Shipped', 'Completed', 'Cancelled'
);

-- 订单明细
CREATE TABLE OrderItems (
    ItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(18,2)
);

-- 产品表
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    CategoryID INT
);

-- 分类表
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName NVARCHAR(50)
);

-- 插入示例数据
INSERT INTO Customers VALUES
(1, '张三', '北京', '2023-01-01'),
(2, '李四', '上海', '2023-02-15'),
(3, '王五', '广州', '2023-03-20');

INSERT INTO Orders VALUES
(101, 1, '2024-01-10', 'Completed'),
(102, 1, '2024-02-15', 'Shipped'),
(103, 2, '2024-01-20', 'Completed'),
(104, 3, '2024-03-01', 'Pending');

INSERT INTO OrderItems VALUES
(1, 101, 1001, 2, 100.00),
(2, 101, 1002, 1, 200.00),
(3, 102, 1001, 3, 100.00),
(4, 103, 1003, 1, 500.00),
(5, 104, 1001, 1, 100.00);

INSERT INTO Categories VALUES
(1, '电子产品'),
(2, '服装');

INSERT INTO Products VALUES
(1001, '手机', 1),
(1002, '耳机', 1),
(1003, 'T恤', 2);
```

完成以下查询：

```sql
-- 1. 查询所有订单详情（包含客户名、产品名、分类名）
SELECT
    o.OrderID,
    c.CustomerName,
    c.City,
    p.ProductName,
    cat.CategoryName,
    oi.Quantity,
    oi.Price,
    oi.Quantity * oi.Price AS Total
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID;

-- 2. 查询每个客户的订单数量和总消费金额
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    ISNULL(SUM(oi.Quantity * oi.Price), 0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.CustomerName;

-- 3. 查询从未下过订单的客户
SELECT c.*
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- 4. 查询购买了"手机"的客户列表
SELECT DISTINCT c.CustomerID, c.CustomerName, c.City
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
WHERE p.ProductName = '手机';

-- 5. 查询每个城市的订单统计
SELECT
    c.City,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    COUNT(DISTINCT c.CustomerID) AS CustomerCount,
    ISNULL(SUM(oi.Quantity * oi.Price), 0) AS TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.City;
```

---

## 第五章：子查询与公用表表达式

### 5.1 子查询类型

```sql
-- 标量子查询：返回单个值
SELECT
    ProductName,
    UnitPrice,
    (SELECT AVG(UnitPrice) FROM Products) AS AvgPrice,
    UnitPrice - (SELECT AVG(UnitPrice) FROM Products) AS Diff
FROM Products;


-- 表子查询：返回多行多列
SELECT * FROM Products
WHERE CategoryID IN (SELECT CategoryID FROM Categories WHERE CategoryName LIKE '%电子%');
```

### 5.2 相关子查询

```sql
-- 查询每个分类中价格最高的产品（相关子查询）
SELECT p1.*
FROM Products p1
WHERE p1.UnitPrice = (
    SELECT MAX(p2.UnitPrice)
    FROM Products p2
    WHERE p2.CategoryID = p1.CategoryID  -- 关联外部查询
);

-- 使用 EXISTS 判断存在性
SELECT c.*
FROM Categories c
WHERE EXISTS (
    SELECT 1 FROM Products p
    WHERE p.CategoryID = c.CategoryID AND p.UnitPrice > 1000
);
```

### 5.3 公用表表达式（CTE）

CTE 是 SQL Server 的重要特性，让复杂查询更易读。

```sql
-- 基础 CTE
WITH CategoryStats AS (
    SELECT
        CategoryID,
        COUNT(*) AS ProductCount,
        AVG(UnitPrice) AS AvgPrice
    FROM Products
    GROUP BY CategoryID
)
SELECT
    c.CategoryName,
    cs.ProductCount,
    cs.AvgPrice
FROM Categories c
INNER JOIN CategoryStats cs ON c.CategoryID = cs.CategoryID;

-- 多 CTE
WITH
OrderSummary AS (
    SELECT
        CustomerID,
        COUNT(*) AS OrderCount,
        SUM(OrderAmount) AS TotalAmount
    FROM Orders
    GROUP BY CustomerID
),
TopCustomers AS (
    SELECT TOP 10 CustomerID
    FROM OrderSummary
    ORDER BY TotalAmount DESC
)
SELECT c.CustomerName, os.*
FROM Customers c
INNER JOIN OrderSummary os ON c.CustomerID = os.CustomerID
WHERE c.CustomerID IN (SELECT CustomerID FROM TopCustomers);
```

### 5.4 递归 CTE（处理层级数据）

这部分我没看懂。。。。。。。

```sql
-- 组织架构表
CREATE TABLE OrgStructure (
    EmployeeID INT PRIMARY KEY,
    EmployeeName NVARCHAR(50),
    ManagerID INT NULL,
    Level INT
);

INSERT INTO OrgStructure VALUES
(1, '总经理', NULL, 1),
(2, '技术总监', 1, 2),
(3, '市场总监', 1, 2),
(4, '开发经理', 2, 3),
(5, '测试经理', 2, 3),
(6, '开发工程师A', 4, 4),
(7, '开发工程师B', 4, 4);

-- 递归查询：获取某员工的所有下属
WITH EmployeeHierarchy AS (
    -- 锚定成员：起始点
    SELECT EmployeeID, EmployeeName, ManagerID, Level,
           CAST(EmployeeName AS NVARCHAR(MAX)) AS Path
    FROM OrgStructure
    WHERE EmployeeID = 2  -- 从技术总监开始

    UNION ALL

    -- 递归成员
    SELECT e.EmployeeID, e.EmployeeName, e.ManagerID, e.Level,
           eh.Path + ' -> ' + e.EmployeeName
    FROM OrgStructure e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT * FROM EmployeeHierarchy;

-- 递归查询：获取某员工的所有上级（反向）
WITH ManagerChain AS (
    SELECT EmployeeID, EmployeeName, ManagerID, Level
    FROM OrgStructure
    WHERE EmployeeID = 6  -- 从开发工程师A开始

    UNION ALL

    SELECT e.EmployeeID, e.EmployeeName, e.ManagerID, e.Level
    FROM OrgStructure e
    INNER JOIN ManagerChain mc ON e.EmployeeID = mc.ManagerID
)
SELECT * FROM ManagerChain;
```

### 本章案例

**案例 5.1：综合子查询与 CTE**

```sql
-- 使用 CTE 简化复杂报表查询
WITH
MonthlySales AS (
    SELECT
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(OrderAmount) AS MonthlyAmount
    FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
SalesWithPrev AS (
    SELECT
        Year,
        Month,
        MonthlyAmount,
        LAG(MonthlyAmount) OVER (ORDER BY Year, Month) AS PrevMonthAmount
    FROM MonthlySales
)
SELECT
    Year,
    Month,
    MonthlyAmount,
    PrevMonthAmount,
    CASE
        WHEN PrevMonthAmount IS NULL THEN NULL
        WHEN PrevMonthAmount = 0 THEN NULL
        ELSE ROUND((MonthlyAmount - PrevMonthAmount) * 100.0 / PrevMonthAmount, 2)
    END AS GrowthRate
FROM SalesWithPrev
ORDER BY Year, Month;
```

---

## 第六章：聚合函数与分组统计

### 6.1 聚合函数

```sql
-- 基本聚合
SELECT
    COUNT(*) AS TotalCount,          -- 总行数
    COUNT(DISTINCT CategoryID) AS CategoryCount,  -- 去重计数
    SUM(UnitPrice) AS TotalPrice,
    AVG(UnitPrice) AS AvgPrice,
    MAX(UnitPrice) AS MaxPrice,
    MIN(UnitPrice) AS MinPrice,
    STDEV(UnitPrice) AS PriceStdDev  -- 标准差
FROM Products;
```

### 6.2 GROUP BY 与 HAVING

```sql
-- 基础分组
SELECT
    CategoryID,
    COUNT(*) AS ProductCount,
    AVG(UnitPrice) AS AvgPrice,
    MIN(UnitPrice) AS MinPrice,
    MAX(UnitPrice) AS MaxPrice
FROM Products
GROUP BY CategoryID;

-- HAVING 过滤分组结果
SELECT
    CategoryID,
    COUNT(*) AS ProductCount,
    AVG(UnitPrice) AS AvgPrice
FROM Products
GROUP BY CategoryID
HAVING COUNT(*) > 5 AND AVG(UnitPrice) > 100;  -- 注意：WHERE 不能过滤聚合结果

-- WHERE vs HAVING
SELECT
    CategoryID,
    COUNT(*) AS ProductCount
FROM Products
WHERE UnitPrice > 50      -- 先过滤行
GROUP BY CategoryID
HAVING COUNT(*) > 5;      -- 再过滤分组
```

### 6.3 高级分组

```sql
-- ROLLUP：小计和总计
SELECT
    COALESCE(CategoryName, '总计') AS Category,
    COALESCE(YEAR(OrderDate), '全部') AS Year,
    SUM(OrderAmount) AS Total
FROM Orders o
JOIN Categories c ON o.CategoryID = c.CategoryID
GROUP BY ROLLUP(CategoryName, YEAR(OrderDate));

-- CUBE：所有组合
SELECT
    CategoryName,
    YEAR(OrderDate) AS Year,
    SUM(OrderAmount) AS Total
FROM Orders o
JOIN Categories c ON o.CategoryID = c.CategoryID
GROUP BY CUBE(CategoryName, YEAR(OrderDate));

-- GROUPING SETS：指定分组组合
SELECT
    CategoryName,
    YEAR(OrderDate) AS Year,
    SUM(OrderAmount) AS Total
FROM Orders o
JOIN Categories c ON o.CategoryID = c.CategoryID
GROUP BY GROUPING SETS (
    (CategoryName, YEAR(OrderDate)),
    (CategoryName),
    (YEAR(OrderDate)),
    ()
);
```

### 6.4 窗口函数（SQL Server 2012+）

窗口函数是企业开发中非常强大的工具。

这里我也没看懂。。。。

```sql
-- 排名函数
SELECT
    ProductName,
    UnitPrice,
    ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) AS RowNum,     -- 连续排名
    RANK() OVER (ORDER BY UnitPrice DESC) AS RankNum,          -- 跳跃排名
    DENSE_RANK() OVER (ORDER BY UnitPrice DESC) AS DenseRank,  -- 密集排名
    NTILE(4) OVER (ORDER BY UnitPrice DESC) AS Quartile        -- 分4组
FROM Products;

-- 分区窗口函数
SELECT
    CategoryID,
    ProductName,
    UnitPrice,
    ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS RankInCategory,
    SUM(UnitPrice) OVER (PARTITION BY CategoryID) AS CategoryTotal
FROM Products;

-- 偏移窗口函数
SELECT
    ProductName,
    UnitPrice,
    LAG(UnitPrice) OVER (ORDER BY UnitPrice) AS PrevPrice,      -- 上一行
    LEAD(UnitPrice) OVER (ORDER BY UnitPrice) AS NextPrice,     -- 下一行
    FIRST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice) AS Lowest, -- 第一行
    LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Highest  -- 最后一行
FROM Products;

-- 累积计算
SELECT
    OrderDate,
    OrderAmount,
    SUM(OrderAmount) OVER (ORDER BY OrderDate) AS RunningTotal,  -- 累计和
    AVG(OrderAmount) OVER (ORDER BY OrderDate ROWS 2 PRECEDING) AS MovingAvg  -- 移动平均
FROM Orders;
```

### 本章案例

**案例 6.1：销售排行榜分析**

```sql
-- 年度销售排名报表
WITH SalesRank AS (
    SELECT
        SalesPersonID,
        SUM(OrderAmount) AS TotalSales,
        COUNT(*) AS OrderCount,
        RANK() OVER (ORDER BY SUM(OrderAmount) DESC) AS SalesRank,
        NTILE(4) OVER (ORDER BY SUM(OrderAmount) DESC) AS PerformanceTier
    FROM Orders
    WHERE YEAR(OrderDate) = 2024
    GROUP BY SalesPersonID
)
SELECT
    sp.SalesPersonName,
    sr.TotalSales,
    sr.OrderCount,
    sr.SalesRank,
    CASE sr.PerformanceTier
        WHEN 1 THEN '优秀'
        WHEN 2 THEN '良好'
        WHEN 3 THEN '合格'
        WHEN 4 THEN '待改进'
    END AS PerformanceLevel
FROM SalesRank sr
JOIN SalesPersons sp ON sr.SalesPersonID = sp.SalesPersonID;
```

---

## 第七章：数据操作语言（DML）

### 7.1 INSERT 操作

```sql
-- 单行插入
INSERT INTO Products (ProductName, CategoryID, UnitPrice)
VALUES ('新产品', 1, 99.99);

-- 多行插入（SQL Server 2008+）
INSERT INTO Products (ProductName, CategoryID, UnitPrice)
VALUES
    ('产品A', 1, 100.00),
    ('产品B', 1, 200.00),
    ('产品C', 2, 150.00);

-- 从其他表插入
INSERT INTO Products_Backup (ProductID, ProductName, UnitPrice)
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE CategoryID = 1;

-- 插入并获取自增ID
INSERT INTO Orders (CustomerID, OrderAmount)
OUTPUT INSERTED.OrderID, INSERTED.OrderDate
VALUES (1, 500.00);

-- 或者使用 SCOPE_IDENTITY()
INSERT INTO Orders (CustomerID, OrderAmount) VALUES (1, 500.00);
SELECT SCOPE_IDENTITY() AS NewOrderID;  -- 当前会话最新自增ID
```

### 7.2 UPDATE 操作

```sql
-- 基础更新
UPDATE Products
SET UnitPrice = UnitPrice * 1.1
WHERE CategoryID = 1;

-- 多列更新
UPDATE Products
SET UnitPrice = 150.00,
    ModifiedDate = GETDATE()
WHERE ProductID = 1;

-- 关联更新（重要！）
UPDATE p
SET p.UnitPrice = p.UnitPrice * c.DiscountRate
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.NeedDiscount = 1;

-- 更新并输出
UPDATE Products
SET UnitPrice = UnitPrice * 0.9
OUTPUT
    DELETED.ProductID,
    DELETED.UnitPrice AS OldPrice,
    INSERTED.UnitPrice AS NewPrice
WHERE CategoryID = 2;
```

### 7.3 DELETE 操作

```sql
-- 基础删除
DELETE FROM OrderDetails WHERE OrderID = 100;

-- 关联删除
DELETE od
FROM OrderDetails od
INNER JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate < '2020-01-01';

-- 删除并输出
DELETE FROM Products
OUTPUT DELETED.*
WHERE ProductID = 999;

-- 安全删除：先查询确认
-- BEGIN TRANSACTION;
-- DELETE FROM ...;  -- 执行删除
-- SELECT * FROM ...; -- 验证结果
-- -- ROLLBACK; 或 COMMIT;
```

### 7.4 MERGE 语句（UPSERT）

MERGE 是强大的批量同步工具。

没看懂。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。

```sql
-- 同步源表到目标表
MERGE INTO TargetTable AS target
USING SourceTable AS source
ON target.ID = source.ID

-- 匹配时更新
WHEN MATCHED THEN
    UPDATE SET
        target.Name = source.Name,
        target.Value = source.Value,
        target.ModifiedDate = GETDATE()

-- 目标表不存在时插入
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ID, Name, Value, CreatedDate)
    VALUES (source.ID, source.Name, source.Value, GETDATE())

-- 源表不存在时删除（可选）
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- 输出变更
MERGE INTO Products AS target
USING Products_Staging AS source
ON target.ProductID = source.ProductID
WHEN MATCHED THEN
    UPDATE SET UnitPrice = source.UnitPrice
WHEN NOT MATCHED THEN
    INSERT (ProductName, UnitPrice) VALUES (source.ProductName, source.UnitPrice)
OUTPUT
    $action AS Action,
    INSERTED.ProductID,
    DELETED.UnitPrice AS OldPrice,
    INSERTED.UnitPrice AS NewPrice;
```

### 本章案例

**案例 7.1：库存更新操作**

```sql
-- 订单确认时扣减库存
CREATE TABLE Inventory (
    ProductID INT PRIMARY KEY,
    Quantity INT NOT NULL,
    ReservedQty INT DEFAULT 0
);

-- 1. 下单时预占库存
UPDATE Inventory
SET ReservedQty = ReservedQty + @OrderQty
WHERE ProductID = @ProductID
  AND Quantity - ReservedQty >= @OrderQty;  -- 确保库存充足

IF @@ROWCOUNT = 0
    RAISERROR('库存不足', 16, 1);

-- 2. 支付成功后确认出库
UPDATE Inventory
SET Quantity = Quantity - @OrderQty,
    ReservedQty = ReservedQty - @OrderQty
WHERE ProductID = @ProductID;

-- 3. 取消订单时释放预占
UPDATE Inventory
SET ReservedQty = ReservedQty - @OrderQty
WHERE ProductID = @ProductID;
```

---

## 第八章：索引设计与优化基础

### 8.1 索引类型

```sql
-- 聚集索引：决定数据物理存储顺序（每张表只能有一个）
CREATE CLUSTERED INDEX IX_Orders_OrderDate
ON Orders(OrderDate);
-- 或通常建在主键上
ALTER TABLE Orders ADD CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderID);

-- 非聚集索引：类似书的目录
CREATE NONCLUSTERED INDEX IX_Products_CategoryID
ON Products(CategoryID);

-- 覆盖索引（Include 列）
CREATE NONCLUSTERED INDEX IX_Products_CategoryID_Cover
ON Products(CategoryID)
INCLUDE (ProductName, UnitPrice);  -- 索引页包含这些列，避免回表

-- 复合索引（列顺序很重要！）
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date
ON Orders(CustomerID, OrderDate);  -- 先CustomerID，再OrderDate

-- 唯一索引
CREATE UNIQUE NONCLUSTERED INDEX IX_Customers_Email
ON Customers(Email);

-- 过滤索引
CREATE NONCLUSTERED INDEX IX_Products_Active
ON Products(CategoryID, UnitPrice)
WHERE IsActive = 1;  -- 只索引活跃产品，减小索引大小
```

### 8.2 索引维护

```sql
-- 查看索引碎片
SELECT
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 30;

-- 重建索引（碎片>30%）
ALTER INDEX IX_Name ON TableName REBUILD;

-- 重组索引（碎片5-30%）
ALTER INDEX IX_Name ON TableName REORGANIZE;

-- 更新统计信息
UPDATE STATISTICS TableName;
```

### 8.3 查询执行计划基础

```sql
-- 查看实际执行计划（SSMS: Ctrl+M）
SET STATISTICS IO ON;   -- 显示IO信息
SET STATISTICS TIME ON; -- 显示执行时间

-- 示例查询
SELECT * FROM Orders WHERE OrderDate > '2024-01-01';
-- 查看消息窗口的扫描次数和执行时间
```

### 本章案例

**案例 8.1：电商常用索引设计**

```sql
-- 订单表索引策略
-- 1. 主键（聚集索引）
ALTER TABLE Orders ADD CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderID);

-- 2. 常用查询条件
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE NONCLUSTERED INDEX IX_Orders_Status ON Orders(Status);

-- 3. 复合索引：客户订单查询（按日期排序）
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date
ON Orders(CustomerID, OrderDate DESC)
INCLUDE (OrderAmount, Status);

-- 4. 订单明细表索引
CREATE NONCLUSTERED INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductID ON OrderDetails(ProductID);
```

---

## 第九章：视图（View）

### 9.1 基础视图

```sql
-- 创建视图
CREATE VIEW vw_ProductDetails
AS
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.UnitPrice,
    p.UnitPrice * 1.1 AS PriceWithTax
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.IsActive = 1;

-- 查询视图
SELECT * FROM vw_ProductDetails WHERE UnitPrice > 100;

-- 修改视图
ALTER VIEW vw_ProductDetails
AS
-- 新定义

-- 删除视图
DROP VIEW IF EXISTS vw_ProductDetails;
```

### 9.2 索引视图（物化视图）

```sql
-- 创建带索引的视图（数据实际存储，提高查询性能）
CREATE VIEW vw_OrderSummary WITH SCHEMABINDING
AS
SELECT
    CustomerID,
    COUNT_BIG(*) AS OrderCount,  -- 必须 COUNT_BIG
    SUM(OrderAmount) AS TotalAmount
FROM dbo.Orders
GROUP BY CustomerID;

-- 创建唯一聚集索引
CREATE UNIQUE CLUSTERED INDEX IX_vw_OrderSummary
ON vw_OrderSummary(CustomerID);

-- 现在视图数据实际存储，查询更快
```

### 9.3 视图的局限性

```sql
-- 可更新视图（需满足条件：单表、无聚合、无DISTINCT等）
CREATE VIEW vw_ActiveProducts
AS
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE IsActive = 1;

-- 可以更新
UPDATE vw_ActiveProducts SET UnitPrice = 200 WHERE ProductID = 1;

-- 插入时需要注意：必须有默认值或允许NULL的列
INSERT INTO vw_ActiveProducts (ProductID, ProductName, UnitPrice)
VALUES (999, '新产品', 100);
```

### 本章案例

**案例 9.1：常用报表视图**

```sql
-- 客户消费统计视图
CREATE VIEW vw_CustomerSpending
AS
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(o.OrderAmount), 0) AS TotalSpent,
    ISNULL(AVG(o.OrderAmount), 0) AS AvgOrderAmount,
    MAX(o.OrderDate) AS LastOrderDate,
    DATEDIFF(DAY, MAX(o.OrderDate), GETDATE()) AS DaysSinceLastOrder
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;

-- 使用视图做客户分层
SELECT
    CustomerID,
    CustomerName,
    CASE
        WHEN TotalSpent > 10000 THEN 'VIP'
        WHEN TotalSpent > 5000 THEN '高级'
        WHEN TotalSpent > 1000 THEN '普通'
        ELSE '新客户'
    END AS CustomerLevel
FROM vw_CustomerSpending;
```

---

## 第十章：存储过程（核心）

存储过程是 SQL Server 企业开发的核心，可以封装业务逻辑、提高性能、增强安全性。

### 10.1 基础存储过程

```sql
-- 创建存储过程
CREATE PROCEDURE sp_GetProductsByCategory
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;  -- 不返回受影响行数，减少网络流量

    SELECT
        ProductID,
        ProductName,
        UnitPrice
    FROM Products
    WHERE CategoryID = @CategoryID
      AND IsActive = 1
    ORDER BY ProductName;
END;

-- 执行
EXEC sp_GetProductsByCategory @CategoryID = 1;

-- 修改
ALTER PROCEDURE sp_GetProductsByCategory
    @CategoryID INT,
    @MinPrice DECIMAL(18,2) = 0  -- 默认值参数
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ProductID,
        ProductName,
        UnitPrice
    FROM Products
    WHERE CategoryID = @CategoryID
      AND UnitPrice >= @MinPrice
      AND IsActive = 1
    ORDER BY ProductName;
END;

-- 执行（带默认值）
EXEC sp_GetProductsByCategory @CategoryID = 1;
EXEC sp_GetProductsByCategory @CategoryID = 1, @MinPrice = 100;
```

### 10.2 带输出参数的存储过程

```sql
-- 带输出参数的存储过程
CREATE PROCEDURE sp_GetOrderStatistics
    @CustomerID INT,
    @TotalOrders INT OUTPUT,
    @TotalAmount DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @TotalOrders = COUNT(*),
        @TotalAmount = ISNULL(SUM(OrderAmount), 0)
    FROM Orders
    WHERE CustomerID = @CustomerID;
END;

-- 调用
DECLARE @Orders INT, @Amount DECIMAL(18,2);
EXEC sp_GetOrderStatistics
    @CustomerID = 1,
    @TotalOrders = @Orders OUTPUT,
    @TotalAmount = @Amount OUTPUT;

SELECT @Orders AS TotalOrders, @Amount AS TotalAmount;
```

### 10.3 带事务的存储过程

```sql
-- 创建订单（带事务）
CREATE PROCEDURE sp_CreateOrder
    @CustomerID INT,
    @OrderItems OrderItemsTableType READONLY,  -- 表值参数
    @NewOrderID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. 创建订单主表
        INSERT INTO Orders (CustomerID, OrderAmount, OrderDate)
        VALUES (@CustomerID, 0, GETDATE());

        SET @NewOrderID = SCOPE_IDENTITY();

        -- 2. 插入订单明细
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @NewOrderID, ProductID, Quantity, UnitPrice
        FROM @OrderItems;

        -- 3. 更新订单总金额
        UPDATE Orders
        SET OrderAmount = (
            SELECT SUM(Quantity * UnitPrice)
            FROM OrderDetails
            WHERE OrderID = @NewOrderID
        )
        WHERE OrderID = @NewOrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 记录错误日志
        INSERT INTO ErrorLog (ErrorMessage, ErrorTime)
        VALUES (ERROR_MESSAGE(), GETDATE());

        -- 抛出错误
        THROW;
    END CATCH;
END;
```

### 10.4 动态 SQL

```sql
-- 动态 SQL（用于灵活查询）
CREATE PROCEDURE sp_DynamicSearch
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID INT = NULL,
    @MinPrice DECIMAL(18,2) = NULL,
    @MaxPrice DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Params NVARCHAR(MAX);

    SET @SQL = N'SELECT * FROM Products WHERE 1=1';

    IF @ProductName IS NOT NULL
        SET @SQL = @SQL + N' AND ProductName LIKE @ProductName + ''%''';

    IF @CategoryID IS NOT NULL
        SET @SQL = @SQL + N' AND CategoryID = @CategoryID';

    IF @MinPrice IS NOT NULL
        SET @SQL = @SQL + N' AND UnitPrice >= @MinPrice';

    IF @MaxPrice IS NOT NULL
        SET @SQL = @SQL + N' AND UnitPrice <= @MaxPrice';

    SET @Params = N'@ProductName NVARCHAR(100), @CategoryID INT, @MinPrice DECIMAL(18,2), @MaxPrice DECIMAL(18,2)';

    EXEC sp_executesql @SQL, @Params,
        @ProductName = @ProductName,
        @CategoryID = @CategoryID,
        @MinPrice = @MinPrice,
        @MaxPrice = @MaxPrice;
END;

-- 执行
EXEC sp_DynamicSearch @CategoryID = 1, @MinPrice = 100;
```

### 10.5 分页存储过程

```sql
-- 通用分页存储过程
CREATE PROCEDURE sp_GetPagedData
    @TableName NVARCHAR(128),
    @SelectColumns NVARCHAR(MAX) = '*',
    @WhereClause NVARCHAR(MAX) = '1=1',
    @OrderBy NVARCHAR(128),
    @PageIndex INT = 1,      -- 页码（从1开始）
    @PageSize INT = 20,      -- 每页条数
    @TotalRecords INT OUTPUT -- 总记录数
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Offset INT = (@PageIndex - 1) * @PageSize;

    -- 获取总记录数
    SET @SQL = N'SELECT @TotalRecords = COUNT(*) FROM ' + QUOTENAME(@TableName) +
               N' WHERE ' + @WhereClause;
    EXEC sp_executesql @SQL, N'@TotalRecords INT OUTPUT', @TotalRecords OUTPUT;

    -- 分页查询
    SET @SQL = N'SELECT ' + @SelectColumns +
               N' FROM ' + QUOTENAME(@TableName) +
               N' WHERE ' + @WhereClause +
               N' ORDER BY ' + @OrderBy +
               N' OFFSET ' + CAST(@Offset AS VARCHAR) + N' ROWS' +
               N' FETCH NEXT ' + CAST(@PageSize AS VARCHAR) + N' ROWS ONLY';

    EXEC sp_executesql @SQL;
END;
```

### 本章案例

**案例 10.1：完整的库存扣减存储过程**

```sql
CREATE PROCEDURE sp_DeductInventory
    @ProductID INT,
    @Quantity INT,
    @OrderID BIGINT,
    @DeductedBy VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentQty INT;
    DECLARE @AvailableQty INT;

    BEGIN TRY
        -- 检查库存（使用 UPDLOCK 防止并发问题）
        SELECT
            @CurrentQty = Quantity,
            @AvailableQty = Quantity - ReservedQty
        FROM Inventory WITH (UPDLOCK, ROWLOCK)
        WHERE ProductID = @ProductID;

        IF @CurrentQty IS NULL
        BEGIN
            RAISERROR('产品不存在', 16, 1);
            RETURN;
        END;

        IF @AvailableQty < @Quantity
        BEGIN
            RAISERROR('库存不足，可用库存：%d', 16, 1, @AvailableQty);
            RETURN;
        END;

        BEGIN TRANSACTION;

        -- 扣减库存
        UPDATE Inventory
        SET Quantity = Quantity - @Quantity,
            ReservedQty = ReservedQty - CASE WHEN ReservedQty >= @Quantity THEN @Quantity ELSE ReservedQty END,
            LastModified = GETDATE(),
            ModifiedBy = @DeductedBy
        WHERE ProductID = @ProductID;

        -- 记录库存变动
        INSERT INTO InventoryLog (ProductID, OrderID, ChangeQty, ChangeType, CreatedBy)
        VALUES (@ProductID, @OrderID, -@Quantity, '出库', @DeductedBy);

        COMMIT TRANSACTION;

        SELECT 1 AS Result, '库存扣减成功' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Result, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```

---

## 第十一章：函数与触发器

### 11.1 标量函数

```sql
-- 创建标量函数
CREATE FUNCTION fn_CalculateAge
(
    @BirthDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SET @Age = DATEDIFF(YEAR, @BirthDate, GETDATE()) 
               CASE
                   WHEN MONTH(@BirthDate) > MONTH(GETDATE())
                        OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
                   THEN 1 	
                   ELSE 0
               END;
    RETURN @Age;
END;

-- 使用
SELECT EmployeeName, dbo.fn_CalculateAge(BirthDate) AS Age FROM Employees;
```

### 11.2 表值函数

```sql
-- 内联表值函数（性能更好）
CREATE FUNCTION fn_GetOrdersByCustomer
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        OrderID,
        OrderDate,
        OrderAmount,
        Status
    FROM Orders
    WHERE CustomerID = @CustomerID
);

-- 使用
SELECT * FROM dbo.fn_GetOrdersByCustomer(1);

-- 多语句表值函数
CREATE FUNCTION fn_GetCustomerOrderSummary
(
    @CustomerID INT
)
RETURNS @Result TABLE
(
    OrderCount INT,
    TotalAmount DECIMAL(18,2),
    LastOrderDate DATE
)
AS
BEGIN
    INSERT INTO @Result
    SELECT
        COUNT(*),
        ISNULL(SUM(OrderAmount), 0),
        MAX(OrderDate)
    FROM Orders
    WHERE CustomerID = @CustomerID;

    RETURN;
END;
```

### 11.3 DML 触发器

```sql
-- AFTER INSERT 触发器
CREATE TRIGGER tr_Orders_AfterInsert
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 记录操作日志
    INSERT INTO AuditLog (TableName, Action, RecordID, NewValue, CreatedDate)
    SELECT
        'Orders',
        'INSERT',
        CAST(i.OrderID AS VARCHAR),
        (SELECT i.* FOR XML RAW),
        GETDATE()
    FROM inserted i;
END;

-- AFTER UPDATE 触发器
CREATE TRIGGER tr_Orders_AfterUpdate
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 只记录变化的字段
    INSERT INTO AuditLog (TableName, Action, RecordID, OldValue, NewValue)
    SELECT
        'Orders',
        'UPDATE',
        CAST(i.OrderID AS VARCHAR),
        (SELECT d.* FOR XML RAW),
        (SELECT i.* FOR XML RAW)
    FROM inserted i
    INNER JOIN deleted d ON i.OrderID = d.OrderID
    WHERE i.Status <> d.Status;  -- 只记录状态变化
END;

-- INSTEAD OF 触发器（用于复杂视图更新）
CREATE TRIGGER tr_vw_Products_InsteadOfInsert
ON vw_ProductDetails
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 插入到实际表
    INSERT INTO Products (ProductName, CategoryID, UnitPrice)
    SELECT
        i.ProductName,
        c.CategoryID,
        i.UnitPrice
    FROM inserted i
    INNER JOIN Categories c ON i.CategoryName = c.CategoryName;
END;
```

### 11.4 DDL 触发器

```sql
-- 监控表结构变更
CREATE TRIGGER tr_DDL_TableChange
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventData XML = EVENTDATA();

    INSERT INTO DDLLog (EventType, ObjectName, ObjectType, TSQLCommand, LoginName, EventDate)
    VALUES (
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(50)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(128)'),
        GETDATE()
    );
END;
```

### 本章案例

**案例 11.1：自动更新修改时间触发器**

```sql
-- 通用触发器：自动更新 ModifiedDate
CREATE TRIGGER tr_Products_AutoUpdateModifiedDate
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 避免递归触发
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE Products
    SET ModifiedDate = GETDATE()
    WHERE ProductID IN (SELECT ProductID FROM inserted);
END;
```

---

## 第十二章：事务与并发控制

### 12.1 事务基础

```sql
-- 基本事务
BEGIN TRANSACTION;

UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;

IF @@ERROR <> 0
    ROLLBACK TRANSACTION;
ELSE
    COMMIT TRANSACTION;

-- 使用 TRY-CATCH 的事务
BEGIN TRY
    BEGIN TRANSACTION;

    -- 业务操作
    INSERT INTO Orders (...) VALUES (...);
    INSERT INTO OrderDetails (...) VALUES (...);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- 错误处理
    THROW;
END CATCH;
```

### 12.2 事务隔离级别

```sql
-- 设置隔离级别
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- 默认
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- 脏读，性能最好
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- 可重复读
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;      -- 串行化，最安全
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;          -- 快照隔离

-- 使用提示（Hint）
SELECT * FROM Orders WITH (NOLOCK);        -- 相当于 READ UNCOMMITTED
SELECT * FROM Orders WITH (HOLDLOCK);      -- 相当于 SERIALIZABLE
SELECT * FROM Orders WITH (UPDLOCK);       -- 更新锁
SELECT * FROM Orders WITH (ROWLOCK);       -- 行锁
SELECT * FROM Orders WITH (READPAST);      -- 跳过已锁定行
```

### 12.3 死锁处理

```sql
-- 查看死锁信息
SELECT
    deadlock_graph
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

-- 在存储过程中处理死锁重试
CREATE PROCEDURE sp_UpdateWithRetry
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RetryCount INT = 0;
    DECLARE @MaxRetries INT = 3;

    WHILE @RetryCount < @MaxRetries
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            -- 业务操作
            UPDATE Accounts WITH (ROWLOCK, UPDLOCK)
            SET Balance = Balance - 100
            WHERE AccountID = 1;

            COMMIT TRANSACTION;
            BREAK;  -- 成功则退出循环
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() = 1205  -- 死锁错误号
            BEGIN
                ROLLBACK TRANSACTION;
                SET @RetryCount = @RetryCount + 1;
                WAITFOR DELAY '00:00:01';  -- 等待1秒后重试
            END
            ELSE
            BEGIN
                IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION;
                THROW;
            END
        END CATCH
    END
END;
```

### 本章案例

**案例 12.1：银行转账（完整事务处理）**

```sql
CREATE PROCEDURE sp_TransferMoney
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Amount <= 0
    BEGIN
        RAISERROR('转账金额必须大于0', 16, 1);
        RETURN;
    END;

    IF @FromAccountID = @ToAccountID
    BEGIN
        RAISERROR('不能给自己转账', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. 检查转出账户余额（加锁）
        DECLARE @FromBalance DECIMAL(18,2);

        SELECT @FromBalance = Balance
        FROM Accounts WITH (UPDLOCK, ROWLOCK)
        WHERE AccountID = @FromAccountID;

        IF @FromBalance IS NULL
        BEGIN
            RAISERROR('转出账户不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @FromBalance < @Amount
        BEGIN
            RAISERROR('余额不足', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 2. 检查转入账户
        IF NOT EXISTS (SELECT 1 FROM Accounts WITH (UPDLOCK, ROWLOCK) WHERE AccountID = @ToAccountID)
        BEGIN
            RAISERROR('转入账户不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 3. 执行转账
        UPDATE Accounts SET Balance = Balance - @Amount WHERE AccountID = @FromAccountID;
        UPDATE Accounts SET Balance = Balance + @Amount WHERE AccountID = @ToAccountID;

        -- 4. 记录交易
        INSERT INTO Transactions (FromAccountID, ToAccountID, Amount, TransactionTime)
        VALUES (@FromAccountID, @ToAccountID, @Amount, GETDATE());

        COMMIT TRANSACTION;

        SELECT 1 AS Success, '转账成功' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 记录错误日志
        INSERT INTO ErrorLog (ProcedureName, ErrorNumber, ErrorMessage, ErrorTime)
        VALUES ('sp_TransferMoney', ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());

        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```

---

## 第十三章：综合实战案例

### 13.1 电商订单系统完整查询

```sql
-- 场景：生成订单综合报表

CREATE PROCEDURE sp_GetOrderReport
    @StartDate DATE,
    @EndDate DATE,
    @CategoryID INT = NULL,
    @CustomerID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH OrderDetailCTE AS (
        SELECT
            o.OrderID,
            o.OrderDate,
            o.CustomerID,
            c.CustomerName,
            od.ProductID,
            p.ProductName,
            p.CategoryID,
            cat.CategoryName,
            od.Quantity,
            od.UnitPrice,
            od.Quantity * od.UnitPrice AS SubTotal
        FROM Orders o
        INNER JOIN Customers c ON o.CustomerID = c.CustomerID
        INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
        INNER JOIN Products p ON od.ProductID = p.ProductID
        INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID
        WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
          AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
          AND (@CustomerID IS NULL OR o.CustomerID = @CustomerID)
    )
    SELECT
        OrderID,
        OrderDate,
        CustomerID,
        CustomerName,
        ProductID,
        ProductName,
        CategoryName,
        Quantity,
        UnitPrice,
        SubTotal,
        SUM(SubTotal) OVER (PARTITION BY OrderID) AS OrderTotal,
        SUM(SubTotal) OVER (PARTITION BY CustomerID) AS CustomerTotal,
        RANK() OVER (PARTITION BY CategoryID ORDER BY SubTotal DESC) AS RankInCategory
    FROM OrderDetailCTE
    ORDER BY OrderDate DESC, OrderID, SubTotal DESC;
END;
```

### 13.2 数据同步存储过程

```sql
-- 同步两个系统的客户数据
CREATE PROCEDURE sp_SyncCustomers
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inserted INT = 0;
    DECLARE @Updated INT = 0;
    DECLARE @Deleted INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. 插入新客户
        INSERT INTO Customers (CustomerID, CustomerName, Email, Phone, SyncTime)
        SELECT s.CustomerID, s.CustomerName, s.Email, s.Phone, GETDATE()
        FROM SourceSystem.Customers s
        LEFT JOIN Customers t ON s.CustomerID = t.CustomerID
        WHERE t.CustomerID IS NULL;

        SET @Inserted = @@ROWCOUNT;

        -- 2. 更新已有客户
        UPDATE t
        SET t.CustomerName = s.CustomerName,
            t.Email = s.Email,
            t.Phone = s.Phone,
            t.SyncTime = GETDATE()
        FROM Customers t
        INNER JOIN SourceSystem.Customers s ON t.CustomerID = s.CustomerID
        WHERE t.CustomerName <> s.CustomerName
           OR t.Email <> s.Email
           OR t.Phone <> s.Phone;

        SET @Updated = @@ROWCOUNT;

        -- 3. 标记已删除客户（软删除）
        UPDATE t
        SET t.IsActive = 0,
            t.SyncTime = GETDATE()
        FROM Customers t
        LEFT JOIN SourceSystem.Customers s ON t.CustomerID = s.CustomerID
        WHERE s.CustomerID IS NULL AND t.IsActive = 1;

        SET @Deleted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- 返回同步结果
        SELECT
            @Inserted AS InsertedCount,
            @Updated AS UpdatedCount,
            @Deleted AS DeletedCount,
            GETDATE() AS SyncTime;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
```

### 13.3 复杂报表查询

```sql
-- 年度销售分析报表
CREATE PROCEDURE sp_GetAnnualSalesReport
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH MonthlyData AS (
        SELECT
            MONTH(OrderDate) AS Month,
            DATENAME(MONTH, OrderDate) AS MonthName,
            COUNT(DISTINCT OrderID) AS OrderCount,
            COUNT(DISTINCT CustomerID) AS CustomerCount,
            SUM(OrderAmount) AS SalesAmount,
            SUM(CASE WHEN OrderAmount > 1000 THEN 1 ELSE 0 END) AS LargeOrders,
            AVG(OrderAmount) AS AvgOrderAmount
        FROM Orders
        WHERE YEAR(OrderDate) = @Year
        GROUP BY MONTH(OrderDate), DATENAME(MONTH, OrderDate)
    )
    SELECT
        Month,
        MonthName,
        OrderCount,
        CustomerCount,
        SalesAmount,
        LargeOrders,
        AvgOrderAmount,
        LAG(SalesAmount) OVER (ORDER BY Month) AS PrevMonthSales,
        SalesAmount - LAG(SalesAmount) OVER (ORDER BY Month) AS MonthOverMonth,
        CASE
            WHEN LAG(SalesAmount) OVER (ORDER BY Month) = 0 THEN NULL
            WHEN LAG(SalesAmount) OVER (ORDER BY Month) IS NULL THEN NULL
            ELSE ROUND((SalesAmount - LAG(SalesAmount) OVER (ORDER BY Month)) * 100.0 /
                       LAG(SalesAmount) OVER (ORDER BY Month), 2)
        END AS GrowthRate,
        SUM(SalesAmount) OVER (ORDER BY Month) AS YearToDateSales
    FROM MonthlyData
    ORDER BY Month;
END;
```

---

## 附录：常用技巧与最佳实践

### A.1 常用系统表和视图

```sql
-- 查看所有表
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- 查看表结构
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders';

-- 查看索引
SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('Orders');

-- 查看存储过程定义
SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GetProductsByCategory'));
-- 或
EXEC sp_helptext 'sp_GetProductsByCategory';

-- 查看当前连接
SELECT * FROM sys.dm_exec_sessions WHERE status = 'sleeping';

-- 查看正在执行的SQL
SELECT
    r.session_id,
    r.status,
    r.start_time,
    r.command,
    t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.status = 'running';
```

### A.2 性能优化 checklist

1. **查询优化**
   - 只查询需要的列，避免 `SELECT *`
   - 使用 EXISTS 代替 IN（子查询数据量大时）
   - 避免在 WHERE 中对字段使用函数
   - 大数据量分页使用 OFFSET/FETCH 或 ROW_NUMBER()

2. **索引优化**
   - 在 WHERE、JOIN、ORDER BY 的列上建索引
   - 定期重建碎片率 > 30% 的索引
   - 使用 INCLUDE 创建覆盖索引
   - 避免过多索引（影响写性能）

3. **事务优化**
   - 事务尽量短小
   - 按相同顺序访问资源，避免死锁
   - 使用合适的隔离级别

### A.3 常用代码模板

```sql
-- 分页查询模板
DECLARE @PageIndex INT = 1;
DECLARE @PageSize INT = 20;

WITH PagedData AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY CreatedDate DESC) AS RowNum
    FROM Products
    WHERE IsActive = 1
)
SELECT * FROM PagedData
WHERE RowNum BETWEEN (@PageIndex - 1) * @PageSize + 1 AND @PageIndex * @PageSize;

-- 批量插入更新模板（MERGE）
MERGE TargetTable AS target
USING SourceTable AS source
ON target.KeyColumn = source.KeyColumn
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...
OUTPUT $action, INSERTED.*, DELETED.*;

-- 递归查询模板
WITH RecursiveCTE AS (
    SELECT ... FROM Table WHERE ParentID IS NULL  -- 锚定
    UNION ALL
    SELECT ... FROM Table t
    INNER JOIN RecursiveCTE r ON t.ParentID = r.ID  -- 递归
)
SELECT * FROM RecursiveCTE;
```

---

**教程结束！请前往 `sqlserver-exercises.md` 完成配套练习。**
