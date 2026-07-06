# SQL Server 练习题库

> 本练习题库与《SQL Server 从入门到精通 - 实战教程》配套使用，共 12 章节，每章 5-8 道题，难度均匀分布。

---

## 数据准备脚本

在做练习题之前，请先执行以下脚本创建练习数据库：

```sql
-- 创建练习数据库
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'SQLExerciseDB')
    DROP DATABASE SQLExerciseDB;
CREATE DATABASE SQLExerciseDB;
GO

USE SQLExerciseDB;
GO

-- 1. 部门表
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL,
    Location NVARCHAR(50),
    ManagerID INT NULL
);

-- 2. 员工表
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName NVARCHAR(50) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    BirthDate DATE,
    HireDate DATE NOT NULL,
    DepartmentID INT,
    Position NVARCHAR(50),
    Salary DECIMAL(18,2),
    Email VARCHAR(100),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- 3. 产品分类表
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- 4. 产品表
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT,
    SupplierID INT,
    UnitPrice DECIMAL(18,2) DEFAULT 0,
    StockQuantity INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 5. 客户表
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(50),
    City NVARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    RegisterDate DATE DEFAULT GETDATE()
);

-- 6. 订单表
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATE,
    ShippedDate DATE,
    ShipCity NVARCHAR(50),
    Freight DECIMAL(18,2) DEFAULT 0,
    Status VARCHAR(20) DEFAULT 'Pending', -- Pending, Processing, Shipped, Completed, Cancelled
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- 7. 订单明细表
CREATE TABLE OrderDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(4,2) DEFAULT 0, -- 折扣率 0-1
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 8. 供应商表
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100),
    ContactName NVARCHAR(50),
    City NVARCHAR(50),
    Phone VARCHAR(20)
);

-- 添加供应商外键
ALTER TABLE Products ADD FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID);

-- 插入示例数据

-- 部门数据
INSERT INTO Departments (DepartmentName, Location) VALUES
('技术部', '北京'),
('销售部', '上海'),
('市场部', '广州'),
('人事部', '北京'),
('财务部', '深圳');

-- 员工数据
INSERT INTO Employees (EmployeeName, Gender, BirthDate, HireDate, DepartmentID, Position, Salary, Email, IsActive) VALUES
('张三', 'M', '1985-03-15', '2020-01-10', 1, '高级工程师', 25000, 'zhangsan@company.com', 1),
('李四', 'F', '1990-07-20', '2019-06-15', 1, '工程师', 18000, 'lisi@company.com', 1),
('王五', 'M', '1988-11-08', '2018-03-20', 1, '技术经理', 35000, 'wangwu@company.com', 1),
('赵六', 'F', '1992-05-12', '2021-09-01', 2, '销售代表', 15000, 'zhaoliu@company.com', 1),
('孙七', 'M', '1983-09-25', '2017-11-10', 2, '销售经理', 30000, 'sunqi@company.com', 1),
('周八', 'F', '1995-01-30', '2022-07-15', 2, '销售代表', 12000, 'zhouba@company.com', 1),
('吴九', 'M', '1987-04-18', '2019-04-01', 3, '市场专员', 16000, 'wujiu@company.com', 1),
('郑十', 'F', '1991-12-05', '2020-08-20', 4, 'HR专员', 14000, 'zhengshi@company.com', 1),
('钱十一', 'M', '1986-06-22', '2018-01-15', 5, '会计', 18000, 'qian11@company.com', 1),
('刘十二', 'F', '1993-08-14', '2023-03-01', 1, '初级工程师', 10000, 'liu12@company.com', 0);

-- 更新部门经理
UPDATE Departments SET ManagerID = 3 WHERE DepartmentID = 1;
UPDATE Departments SET ManagerID = 5 WHERE DepartmentID = 2;
UPDATE Departments SET ManagerID = 7 WHERE DepartmentID = 3;

-- 产品分类数据
INSERT INTO Categories (CategoryName, Description) VALUES
('电子产品', '手机、电脑、配件等'),
('服装', '男装、女装、童装'),
('食品', '零食、饮料、生鲜'),
('家居', '家具、家纺、厨具'),
('图书', '各类书籍');

-- 供应商数据
INSERT INTO Suppliers (SupplierName, ContactName, City, Phone) VALUES
('科技有限公司', '张经理', '深圳', '0755-12345678'),
('服装批发城', '李老板', '广州', '020-87654321'),
('食品供应商', '王先生', '上海', '021-11112222'),
('家居制造厂', '陈女士', '佛山', '0757-33334444'),
('图书发行社', '赵先生', '北京', '010-55556666');

-- 产品数据
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, StockQuantity, IsActive) VALUES
('iPhone 15', 1, 1, 6999, 100, 1),
('MacBook Pro', 1, 1, 14999, 50, 1),
('无线耳机', 1, 1, 999, 200, 1),
('男士T恤', 2, 2, 99, 500, 1),
('女士连衣裙', 2, 2, 299, 300, 1),
('牛仔裤', 2, 2, 199, 400, 1),
('巧克力', 3, 3, 59, 1000, 1),
('咖啡', 3, 3, 89, 800, 1),
('坚果礼盒', 3, 3, 188, 200, 1),
('沙发', 4, 4, 3999, 20, 1),
('餐桌', 4, 4, 2599, 30, 1),
('SQL Server从入门到精通', 5, 5, 89, 100, 1),
('Python编程', 5, 5, 79, 150, 1),
('老款手机', 1, 1, 1999, 10, 0);

-- 客户数据
INSERT INTO Customers (CustomerName, ContactName, City, Phone, Email, RegisterDate) VALUES
('北京科技有限公司', '张先生', '北京', '13800138000', 'bjtech@email.com', '2023-01-15'),
('上海贸易公司', '李女士', '上海', '13900139000', 'shtrade@email.com', '2023-02-20'),
('广州百货商场', '王经理', '广州', '13700137000', 'gzstore@email.com', '2023-03-10'),
('深圳电子城', '陈先生', '深圳', '13600136000', 'szelec@email.com', '2023-04-05'),
('杭州网络科技', '赵女士', '杭州', '13500135000', 'hznet@email.com', '2023-05-18'),
('个人客户甲', '刘先生', '北京', '13400134000', 'personal1@email.com', '2023-06-20'),
('个人客户乙', '周女士', '上海', '13300133000', 'personal2@email.com', '2023-07-25'),
('武汉商贸公司', '吴先生', '武汉', '13200132000', 'whbiz@email.com', '2023-08-30');

-- 订单数据
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipCity, Freight, Status) VALUES
(1, 4, '2024-01-10', '2024-01-15', '2024-01-12', '北京', 50, 'Completed'),
(1, 4, '2024-02-05', '2024-02-10', '2024-02-08', '北京', 50, 'Completed'),
(2, 5, '2024-01-15', '2024-01-20', '2024-01-18', '上海', 80, 'Completed'),
(3, 4, '2024-03-01', '2024-03-05', NULL, '广州', 60, 'Processing'),
(4, 6, '2024-02-20', '2024-02-25', '2024-02-22', '深圳', 70, 'Completed'),
(5, 5, '2024-03-10', '2024-03-15', NULL, '杭州', 90, 'Pending'),
(6, 4, '2024-01-25', '2024-01-30', '2024-01-28', '北京', 30, 'Completed'),
(7, 6, '2024-02-15', '2024-02-20', '2024-02-18', '上海', 40, 'Completed'),
(8, 5, '2024-03-05', '2024-03-10', NULL, '武汉', 100, 'Cancelled'),
(1, 4, '2024-03-20', '2024-03-25', NULL, '北京', 50, 'Pending');

-- 订单明细数据
INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES
(1, 1, 6999, 2, 0.05),
(1, 3, 999, 5, 0),
(2, 2, 14999, 1, 0),
(3, 4, 99, 50, 0.1),
(3, 5, 299, 30, 0.1),
(4, 7, 59, 100, 0.05),
(4, 8, 89, 80, 0),
(5, 10, 3999, 2, 0),
(5, 11, 2599, 3, 0),
(6, 1, 6999, 3, 0.1),
(7, 12, 89, 20, 0),
(8, 6, 199, 10, 0),
(8, 9, 188, 5, 0),
(9, 2, 14999, 1, 0),
(10, 3, 999, 10, 0.05);

PRINT '练习数据库初始化完成！';
```

---

## 第一章：SQL Server 基础与环境（5题）

### 题目 1.1
查询当前 SQL Server 的版本信息。

<details>
<summary>参考答案</summary>

```sql
SELECT @@VERSION;
```
</details>

### 题目 1.2
查看 SQLExerciseDB 数据库中所有用户表的数量。

<details>
<summary>参考答案</summary>

```sql
USE SQLExerciseDB;
SELECT COUNT(*) AS TableCount
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
```
</details>

### 题目 1.3
查询 Employees 表的列信息，包括列名、数据类型、是否允许为空。

<details>
<summary>参考答案</summary>

```sql
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees'
ORDER BY ORDINAL_POSITION;
```
</details>

### 题目 1.4
格式化显示当前日期为 "2024年01月15日" 的格式。

<details>
<summary>参考答案</summary>

```sql
SELECT FORMAT(GETDATE(), 'yyyy年MM月dd日');
-- 或
SELECT CONVERT(VARCHAR, GETDATE(), 111) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);
```
</details>

### 题目 1.5
查询 Employees 表中所有员工，显示：员工姓名、年龄（周岁）、入职年限。

<details>
<summary>参考答案</summary>

```sql
SELECT
    EmployeeName,
    DATEDIFF(YEAR, BirthDate, GETDATE()) -
        CASE WHEN MONTH(BirthDate) > MONTH(GETDATE())
                  OR (MONTH(BirthDate) = MONTH(GETDATE()) AND DAY(BirthDate) > DAY(GETDATE()))
             THEN 1 ELSE 0
        END AS Age,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS WorkYears
FROM Employees;
```
</details>

---

## 第二章：数据类型与表设计（6题）

### 题目 2.1
创建一个名为 `ProductReviews` 的评论表，包含以下字段：
- ReviewID（自增主键）
- ProductID（外键关联 Products）
- CustomerID（外键关联 Customers，可空）
- Rating（1-5的整数）
- Comment（评论内容，最多500字）
- ReviewDate（评论时间，默认当前时间）
- IsApproved（是否审核通过，默认0）

<details>
<summary>参考答案</summary>

```sql
CREATE TABLE ProductReviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL,
    CustomerID INT NULL,
    Rating INT NOT NULL,
    Comment NVARCHAR(500),
    ReviewDate DATETIME DEFAULT GETDATE(),
    IsApproved BIT DEFAULT 0,
    CONSTRAINT FK_Review_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_Review_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CK_Rating CHECK (Rating BETWEEN 1 AND 5)
);
```
</details>

### 题目 2.2
向 ProductReviews 表插入3条测试数据。

<details>
<summary>参考答案</summary>

```sql
INSERT INTO ProductReviews (ProductID, CustomerID, Rating, Comment, IsApproved) VALUES
(1, 1, 5, '非常好用，强烈推荐！', 1),
(1, 2, 4, '不错，就是价格有点贵', 1),
(2, 3, 5, '性能强劲，办公神器', 0);
```
</details>

### 题目 2.3
创建一个临时表 #TempTopProducts，包含产品ID和总销售额两列，将销量最高的3个产品插入该表。

<details>
<summary>参考答案</summary>

```sql
CREATE TABLE #TempTopProducts (
    ProductID INT,
    TotalSales DECIMAL(18,2)
);

INSERT INTO #TempTopProducts
SELECT TOP 3
    p.ProductID,
    ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSales
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID
ORDER BY TotalSales DESC;

SELECT * FROM #TempTopProducts;

DROP TABLE #TempTopProducts;
```
</details>

### 题目 2.4
修改 Orders 表，添加一个计算列 `TotalAmount`，自动计算订单总金额（需要根据 OrderDetails 计算，这里先做演示结构）。

<details>
<summary>参考答案</summary>

```sql
-- 添加计算列需要基于表中已有列，这里添加一个示例
ALTER TABLE Orders ADD OrderYear AS (YEAR(OrderDate));

-- 查看效果
SELECT OrderID, OrderDate, OrderYear FROM Orders;
```
</details>

### 题目 2.5
创建一张表变量 @NewSuppliers，插入两条新供应商记录，然后查询该表变量。

<details>
<summary>参考答案</summary>

```sql
DECLARE @NewSuppliers TABLE (
    SupplierName NVARCHAR(100),
    City NVARCHAR(50),
    Phone VARCHAR(20)
);

INSERT INTO @NewSuppliers VALUES
('新供应商A', '成都', '028-12345678'),
('新供应商B', '西安', '029-87654321');

SELECT * FROM @NewSuppliers;
```
</details>

### 题目 2.6
删除 ProductReviews 表中的所有数据，但保留表结构。

<details>
<summary>参考答案</summary>

```sql
-- 方法1
DELETE FROM ProductReviews;

-- 方法2（更快，重置自增列）
TRUNCATE TABLE ProductReviews;
```
</details>

---

## 第三章：基础查询与条件过滤（8题）

### 题目 3.1
查询 Employees 表中所有在职（IsActive=1）的员工，只显示姓名、职位、薪资。

<details>
<summary>参考答案</summary>

```sql
SELECT EmployeeName, Position, Salary
FROM Employees
WHERE IsActive = 1;
```
</details>

### 题目 3.2
查询薪资在 15000 到 25000 之间（含）的员工信息。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Employees
WHERE Salary BETWEEN 15000 AND 25000;
```
</details>

### 题目 3.3
查询姓名中包含"张"、"李"、"王"任意一个姓氏的员工。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Employees
WHERE EmployeeName LIKE '张%'
   OR EmployeeName LIKE '李%'
   OR EmployeeName LIKE '王%';
```
</details>

### 题目 3.4
查询邮箱域名为 @company.com 的员工列表。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Employees
WHERE Email LIKE '%@company.com';
```
</details>

### 题目 3.5
查询 2020 年及以后入职的员工，按薪资从高到低排序。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Employees
WHERE HireDate >= '2020-01-01'
ORDER BY Salary DESC;
```
</details>

### 题目 3.6
查询 Products 表中库存数量少于 100 或者已停售（IsActive=0）的产品。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Products
WHERE StockQuantity < 100
   OR IsActive = 0;
```
</details>

### 题目 3.7
查询 Orders 表中状态为"Cancelled"或"Pending"的订单，要求只显示前5条。

<details>
<summary>参考答案</summary>

```sql
SELECT TOP 5 *
FROM Orders
WHERE Status IN ('Cancelled', 'Pending');
```
</details>

### 题目 3.8
查询 Employees 表，统计不同职位的员工数量（不使用 GROUP BY，只列出数据）。

<details>
<summary>参考答案</summary>

```sql
SELECT
    Position,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Position;
```
</details>

---

## 第四章：多表关联查询（核心）（10题）

### 题目 4.1
查询所有订单信息，包含客户名称和负责销售的员工姓名。

<details>
<summary>参考答案</summary>

```sql
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    e.EmployeeName AS SalesPerson
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID;
```
</details>

### 题目 4.2
查询每个订单的详细信息：订单ID、客户名、产品名、数量、单价、小计金额（数量*单价*(1-折扣)）。

<details>
<summary>参考答案</summary>

```sql
SELECT
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice * (1 - od.Discount) AS SubTotal
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;
```
</details>

### 题目 4.3
查询所有下过订单的客户列表（去重）。

<details>
<summary>参考答案</summary>

```sql
SELECT DISTINCT c.CustomerID, c.CustomerName, c.City
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;
```
</details>

### 题目 4.4
查询所有从未下过订单的客户。

<details>
<summary>参考答案</summary>

```sql
SELECT c.*
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
```
</details>

### 题目 4.5
查询每个员工的订单数量和总销售额（包括没有订单的员工）。

<details>
<summary>参考答案</summary>

```sql
SELECT
    e.EmployeeID,
    e.EmployeeName,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSales
FROM Employees e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.EmployeeName;
```
</details>

### 题目 4.6
查询购买了"iPhone 15"的所有客户名称和购买数量。

<details>
<summary>参考答案</summary>

```sql
SELECT
    c.CustomerName,
    SUM(od.Quantity) AS TotalQuantity
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE p.ProductName = 'iPhone 15'
GROUP BY c.CustomerID, c.CustomerName;
```
</details>

### 题目 4.7
查询每个部门的员工数量和平均薪资。

<details>
<summary>参考答案</summary>

```sql
SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    AVG(e.Salary) AS AvgSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
GROUP BY d.DepartmentID, d.DepartmentName;
```
</details>

### 题目 4.8
查询同时购买过"iPhone 15"和"MacBook Pro"的客户。

<details>
<summary>参考答案</summary>

```sql
SELECT c.CustomerID, c.CustomerName
FROM Customers c
WHERE c.CustomerID IN (
    SELECT o.CustomerID
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE p.ProductName = 'iPhone 15'
)
AND c.CustomerID IN (
    SELECT o.CustomerID
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE p.ProductName = 'MacBook Pro'
);
```
</details>

### 题目 4.9
查询每个分类的产品数量和平均价格，只显示有产品的分类。

<details>
<summary>参考答案</summary>

```sql
SELECT
    c.CategoryName,
    COUNT(p.ProductID) AS ProductCount,
    AVG(p.UnitPrice) AS AvgPrice
FROM Categories c
INNER JOIN Products p ON c.CategoryID = p.CategoryID
WHERE p.IsActive = 1
GROUP BY c.CategoryID, c.CategoryName;
```
</details>

### 题目 4.10
查询每个城市的客户数量、订单数量和总订单金额。

<details>
<summary>参考答案</summary>

```sql
SELECT
    c.City,
    COUNT(DISTINCT c.CustomerID) AS CustomerCount,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.City;
```
</details>

---

## 第五章：子查询与公用表表达式（7题）

### 题目 5.1
使用子查询找出薪资高于公司平均薪资的员工。

<details>
<summary>参考答案</summary>

```sql
SELECT *
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1);
```
</details>

### 题目 5.2
使用子查询找出每个分类中价格最高的产品。

<details>
<summary>参考答案</summary>

```sql
SELECT p.*
FROM Products p
WHERE p.UnitPrice = (
    SELECT MAX(UnitPrice)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
);
```
</details>

### 题目 5.3
使用 EXISTS 查询有订单明细的订单列表。

<details>
<summary>参考答案</summary>

```sql
SELECT o.*
FROM Orders o
WHERE EXISTS (
    SELECT 1 FROM OrderDetails od WHERE od.OrderID = o.OrderID
);
```
</details>

### 题目 5.4
使用 CTE 查询每个客户的订单数量和总消费金额，然后筛选出消费超过 10000 的客户。

<details>
<summary>参考答案</summary>

```sql
WITH CustomerSpending AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        COUNT(o.OrderID) AS OrderCount,
        ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSpent
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT *
FROM CustomerSpending
WHERE TotalSpent > 10000;
```
</details>

### 题目 5.5
使用 CTE 查询 2024 年 1 月的订单，并计算每日订单数量和累计订单金额。

<details>
<summary>参考答案</summary>

```sql
WITH DailyOrders AS (
    SELECT
        CAST(OrderDate AS DATE) AS OrderDay,
        COUNT(*) AS OrderCount,
        SUM(OrderAmount) AS DayAmount
    FROM Orders
    WHERE OrderDate >= '2024-01-01' AND OrderDate < '2024-02-01'
    GROUP BY CAST(OrderDate AS DATE)
)
SELECT
    OrderDay,
    OrderCount,
    DayAmount,
    SUM(DayAmount) OVER (ORDER BY OrderDay) AS RunningTotal
FROM DailyOrders
ORDER BY OrderDay;
```
</details>

### 题目 5.6
使用递归 CTE 查询员工"李四"（EmployeeID=2）的所有上级（一直到总经理）。

<details>
<summary>参考答案</summary>

```sql
WITH EmployeeHierarchy AS (
    -- 从李四开始
    SELECT e.EmployeeID, e.EmployeeName, e.DepartmentID, d.ManagerID, 0 AS Level
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.EmployeeID = 2

    UNION ALL

    -- 递归查找上级部门的经理
    SELECT e.EmployeeID, e.EmployeeName, e.DepartmentID, d.ManagerID, eh.Level + 1
    FROM EmployeeHierarchy eh
    JOIN Employees e ON eh.ManagerID = e.EmployeeID
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE eh.ManagerID IS NOT NULL
)
SELECT * FROM EmployeeHierarchy;
```
</details>

### 题目 5.7
使用多个 CTE 查询每个分类的销售情况，并与该分类的平均单价比较。

<details>
<summary>参考答案</summary>

```sql
WITH CategorySales AS (
    SELECT
        c.CategoryID,
        c.CategoryName,
        ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSales,
        ISNULL(SUM(od.Quantity), 0) AS TotalQuantity
    FROM Categories c
    LEFT JOIN Products p ON c.CategoryID = p.CategoryID
    LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryID, c.CategoryName
),
CategoryAvgPrice AS (
    SELECT
        CategoryID,
        AVG(UnitPrice) AS AvgPrice
    FROM Products
    WHERE IsActive = 1
    GROUP BY CategoryID
)
SELECT
    cs.CategoryName,
    cs.TotalSales,
    cs.TotalQuantity,
    cap.AvgPrice
FROM CategorySales cs
LEFT JOIN CategoryAvgPrice cap ON cs.CategoryID = cap.CategoryID;
```
</details>

---

## 第六章：聚合函数与分组统计（8题）

### 题目 6.1
统计 Orders 表中各种状态的订单数量。

<details>
<summary>参考答案</summary>

```sql
SELECT
    Status,
    COUNT(*) AS OrderCount
FROM Orders
GROUP BY Status;
```
</details>

### 题目 6.2
统计每个客户的订单数量和平均订单金额，只显示有订单的客户。

<details>
<summary>参考答案</summary>

```sql
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    AVG(o.OrderAmount) AS AvgOrderAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;
```
</details>

### 题目 6.3
统计 2024 年每个月的订单数量、订单总金额、最大单笔金额。

<details>
<summary>参考答案</summary>

```sql
SELECT
    MONTH(OrderDate) AS Month,
    COUNT(*) AS OrderCount,
    SUM(OrderAmount) AS TotalAmount,
    MAX(OrderAmount) AS MaxOrderAmount
FROM Orders
WHERE YEAR(OrderDate) = 2024
GROUP BY MONTH(OrderDate)
ORDER BY Month;
```
</details>

### 题目 6.4
查询产品销量排行榜前5名（按销售数量）。

<details>
<summary>参考答案</summary>

```sql
SELECT TOP 5
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalSold
FROM Products p
INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSold DESC;
```
</details>

### 题目 6.5
使用 HAVING 筛选出有3个以上员工的部门。

<details>
<summary>参考答案</summary>

```sql
SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
GROUP BY d.DepartmentID, d.DepartmentName
HAVING COUNT(e.EmployeeID) >= 3;
```
</details>

### 题目 6.6
使用 ROLLUP 统计每个部门的员工数量和薪资小计、总计。

<details>
<summary>参考答案</summary>

```sql
SELECT
    ISNULL(d.DepartmentName, '总计') AS Department,
    COUNT(e.EmployeeID) AS EmployeeCount,
    SUM(e.Salary) AS TotalSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
GROUP BY ROLLUP(d.DepartmentName);
```
</details>

### 题目 6.7
使用窗口函数查询每个员工在部门内的薪资排名。

<details>
<summary>参考答案</summary>

```sql
SELECT
    e.EmployeeName,
    d.DepartmentName,
    e.Salary,
    RANK() OVER (PARTITION BY e.DepartmentID ORDER BY e.Salary DESC) AS DeptRank,
    RANK() OVER (ORDER BY e.Salary DESC) AS OverallRank
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1;
```
</details>

### 题目 6.8
使用窗口函数计算每个产品累计销售额占分类总销售额的比例。

<details>
<summary>参考答案</summary>

```sql
WITH ProductSales AS (
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS ProductSales
    FROM Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
    GROUP BY p.ProductID, p.ProductName, c.CategoryName
)
SELECT
    ProductID,
    ProductName,
    CategoryName,
    ProductSales,
    SUM(ProductSales) OVER (PARTITION BY CategoryName) AS CategoryTotal,
    ROUND(ProductSales * 100.0 / SUM(ProductSales) OVER (PARTITION BY CategoryName), 2) AS SalesPercentage
FROM ProductSales
WHERE ProductSales > 0;
```
</details>

---

## 第七章：数据操作语言（7题）

### 题目 7.1
向 Suppliers 表插入一条新供应商记录。

<details>
<summary>参考答案</summary>

```sql
INSERT INTO Suppliers (SupplierName, ContactName, City, Phone)
VALUES ('成都科技有限公司', '周经理', '成都', '028-88889999');
```
</details>

### 题目 7.2
将所有库存数量小于 50 的产品的价格上调 10%。

<details>
<summary>参考答案</summary>

```sql
UPDATE Products
SET UnitPrice = UnitPrice * 1.1
WHERE StockQuantity < 50;
```
</details>

### 题目 7.3
删除 2023 年 12 月 31 日之前注册且从未下过订单的客户。

<details>
<summary>参考答案</summary>

```sql
DELETE FROM Customers
WHERE RegisterDate < '2024-01-01'
  AND CustomerID NOT IN (SELECT CustomerID FROM Orders);
```
</details>

### 题目 7.4
使用关联更新，将所有"电子产品"分类的产品价格下调 5%。

<details>
<summary>参考答案</summary>

```sql
UPDATE p
SET p.UnitPrice = p.UnitPrice * 0.95
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = '电子产品';
```
</details>

### 题目 7.5
创建 Products 表的备份表 Products_Backup，并将所有数据复制过去。

<details>
<summary>参考答案</summary>

```sql
-- 创建备份表结构
SELECT * INTO Products_Backup FROM Products WHERE 1=0;

-- 插入数据
INSERT INTO Products_Backup
SELECT * FROM Products;

-- 查看结果
SELECT * FROM Products_Backup;
```
</details>

### 题目 7.6
使用 MERGE 语句同步 Products 和 Products_Backup，使两者数据一致。

<details>
<summary>参考答案</summary>

```sql
MERGE INTO Products_Backup AS target
USING Products AS source
ON target.ProductID = source.ProductID

WHEN MATCHED THEN
    UPDATE SET
        target.ProductName = source.ProductName,
        target.UnitPrice = source.UnitPrice,
        target.StockQuantity = source.StockQuantity

WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, CategoryID, SupplierID, UnitPrice, StockQuantity, IsActive)
    VALUES (source.ProductID, source.ProductName, source.CategoryID, source.SupplierID, source.UnitPrice, source.StockQuantity, source.IsActive)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
```
</details>

### 题目 7.7
更新订单状态：将所有超过 RequiredDate 3天还未发货的订单状态改为 'Delayed'。

<details>
<summary>参考答案</summary>

```sql
UPDATE Orders
SET Status = 'Delayed'
WHERE Status IN ('Pending', 'Processing')
  AND ShippedDate IS NULL
  AND RequiredDate < DATEADD(DAY, -3, GETDATE());
```
</details>

---

## 第八章：索引设计与优化基础（5题）

### 题目 8.1
为 Employees 表的 Email 列创建唯一索引。

<details>
<summary>参考答案</summary>

```sql
CREATE UNIQUE INDEX IX_Employees_Email ON Employees(Email);
```
</details>

### 题目 8.2
为 Orders 表的 (CustomerID, OrderDate) 列创建复合索引。

<details>
<summary>参考答案</summary>

```sql
CREATE INDEX IX_Orders_Customer_Date ON Orders(CustomerID, OrderDate DESC);
```
</details>

### 题目 8.3
为 Products 表创建一个覆盖索引，包含 CategoryID 和 UnitPrice，并包含 ProductName 列。

<details>
<summary>参考答案</summary>

```sql
CREATE INDEX IX_Products_Category_Cover ON Products(CategoryID, UnitPrice)
INCLUDE (ProductName);
```
</details>

### 题目 8.4
查看 Orders 表上所有索引的碎片情况。

<details>
<summary>参考答案</summary>

```sql
SELECT
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Orders'), NULL, NULL, 'LIMITED');
```
</details>

### 题目 8.5
使用 SET STATISTICS 查看一个查询的 IO 和时间开销。

<details>
<summary>参考答案</summary>

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.OrderDate > '2024-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```
</details>

---

## 第九章：视图（6题）

### 题目 9.1
创建一个视图 vw_ActiveEmployees，只显示在职员工的基本信息。

<details>
<summary>参考答案</summary>

```sql
CREATE VIEW vw_ActiveEmployees
AS
SELECT
    EmployeeID,
    EmployeeName,
    Gender,
    Position,
    Salary,
    DepartmentID
FROM Employees
WHERE IsActive = 1;
```
</details>

### 题目 9.2
创建一个视图 vw_OrderFullInfo，包含订单的完整信息（客户名、员工名、产品明细）。

<details>
<summary>参考答案</summary>

```sql
CREATE VIEW vw_OrderFullInfo
AS
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    e.EmployeeName AS SalesPerson,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    od.Quantity * od.UnitPrice * (1 - od.Discount) AS LineTotal
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;
```
</details>

### 题目 9.3
查询视图 vw_OrderFullInfo，筛选出 2024 年的订单。

<details>
<summary>参考答案</summary>

```sql
SELECT * FROM vw_OrderFullInfo
WHERE YEAR(OrderDate) = 2024;
```
</details>

### 题目 9.4
创建一个视图 vw_EmployeeDepartment，显示员工姓名和部门名称。

<details>
<summary>参考答案</summary>

```sql
CREATE VIEW vw_EmployeeDepartment
AS
SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Position,
    d.DepartmentName,
    d.Location
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID;
```
</details>

### 题目 9.5
删除视图 vw_ActiveEmployees。

<details>
<summary>参考答案</summary>

```sql
DROP VIEW IF EXISTS vw_ActiveEmployees;
```
</details>

### 题目 9.6
创建一个视图 vw_ProductInventory，显示产品库存状态（库存 < 50 显示"库存不足"，50-200 显示"库存正常"，>200 显示"库存充足"）。

<details>
<summary>参考答案</summary>

```sql
CREATE VIEW vw_ProductInventory
AS
SELECT
    ProductID,
    ProductName,
    StockQuantity,
    CASE
        WHEN StockQuantity < 50 THEN '库存不足'
        WHEN StockQuantity BETWEEN 50 AND 200 THEN '库存正常'
        ELSE '库存充足'
    END AS StockStatus
FROM Products
WHERE IsActive = 1;
```
</details>

---

## 第十章：存储过程（核心）（10题）

### 题目 10.1
创建一个存储过程 sp_GetEmployeeByDepartment，根据部门ID查询该部门所有员工。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetEmployeeByDepartment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Employees
    WHERE DepartmentID = @DepartmentID AND IsActive = 1;
END;

-- 执行
EXEC sp_GetEmployeeByDepartment @DepartmentID = 1;
```
</details>

### 题目 10.2
创建一个存储过程 sp_GetProductSales，根据产品ID返回该产品的总销售数量和总销售额（使用输出参数）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetProductSales
    @ProductID INT,
    @TotalQuantity INT OUTPUT,
    @TotalSales DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @TotalQuantity = ISNULL(SUM(Quantity), 0),
        @TotalSales = ISNULL(SUM(Quantity * UnitPrice * (1 - Discount)), 0)
    FROM OrderDetails
    WHERE ProductID = @ProductID;
END;

-- 执行
DECLARE @Qty INT, @Sales DECIMAL(18,2);
EXEC sp_GetProductSales @ProductID = 1, @TotalQuantity = @Qty OUTPUT, @TotalSales = @Sales OUTPUT;
SELECT @Qty AS TotalQuantity, @Sales AS TotalSales;
```
</details>

### 题目 10.3
创建一个存储过程 sp_UpdateOrderStatus，更新订单状态，如果订单不存在则返回错误信息。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_UpdateOrderStatus
    @OrderID INT,
    @NewStatus VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        RAISERROR('订单不存在', 16, 1);
        RETURN;
    END;

    UPDATE Orders
    SET Status = @NewStatus,
        ShippedDate = CASE WHEN @NewStatus = 'Shipped' THEN GETDATE() ELSE ShippedDate END
    WHERE OrderID = @OrderID;

    SELECT 1 AS Success, '状态更新成功' AS Message;
END;
```
</details>

### 题目 10.4
创建一个带分页的存储过程 sp_GetProductsPaged。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetProductsPaged
    @PageIndex INT = 1,
    @PageSize INT = 10,
    @TotalCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalCount = COUNT(*) FROM Products WHERE IsActive = 1;

    SELECT *
    FROM Products
    WHERE IsActive = 1
    ORDER BY ProductID
    OFFSET (@PageIndex - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

-- 执行
DECLARE @Total INT;
EXEC sp_GetProductsPaged @PageIndex = 1, @PageSize = 5, @TotalCount = @Total OUTPUT;
SELECT @Total AS TotalRecords;
```
</details>

### 题目 10.5
创建一个存储过程 sp_CreateCustomer，插入新客户并返回新客户ID。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_CreateCustomer
    @CustomerName NVARCHAR(100),
    @ContactName NVARCHAR(50),
    @City NVARCHAR(50),
    @Phone VARCHAR(20),
    @Email VARCHAR(100),
    @NewCustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Customers (CustomerName, ContactName, City, Phone, Email)
    VALUES (@CustomerName, @ContactName, @City, @Phone, @Email);

    SET @NewCustomerID = SCOPE_IDENTITY();
END;

-- 执行
DECLARE @NewID INT;
EXEC sp_CreateCustomer
    @CustomerName = '新客户',
    @ContactName = '联系人',
    @City = '南京',
    @Phone = '025-12345678',
    @Email = 'new@email.com',
    @NewCustomerID = @NewID OUTPUT;
SELECT @NewID AS NewCustomerID;
```
</details>

### 题目 10.6
创建一个使用动态 SQL 的存储过程 sp_SearchProducts，支持按产品名模糊查询和分类ID筛选。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_SearchProducts
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Products WHERE IsActive = 1';

    IF @ProductName IS NOT NULL
        SET @SQL = @SQL + ' AND ProductName LIKE @ProductName + ''%''';

    IF @CategoryID IS NOT NULL
        SET @SQL = @SQL + ' AND CategoryID = @CategoryID';

    SET @SQL = @SQL + ' ORDER BY ProductName';

    EXEC sp_executesql @SQL,
        N'@ProductName NVARCHAR(100), @CategoryID INT',
        @ProductName = @ProductName,
        @CategoryID = @CategoryID;
END;

-- 执行
EXEC sp_SearchProducts @ProductName = 'iPhone', @CategoryID = 1;
```
</details>

### 题目 10.7
创建一个存储过程 sp_GetMonthlySalesReport，返回指定年份的月度销售报表。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetMonthlySalesReport
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MONTH(o.OrderDate) AS Month,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        COUNT(DISTINCT o.CustomerID) AS CustomerCount,
        SUM(od.Quantity) AS TotalQuantity,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = @Year
    GROUP BY MONTH(o.OrderDate)
    ORDER BY Month;
END;

-- 执行
EXEC sp_GetMonthlySalesReport @Year = 2024;
```
</details>

### 题目 10.8
创建一个存储过程 sp_DeleteOrder，删除订单及其明细（使用事务）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_DeleteOrder
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 先删除明细
        DELETE FROM OrderDetails WHERE OrderID = @OrderID;

        -- 再删除主表
        DELETE FROM Orders WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;

        SELECT 1 AS Success, '订单删除成功' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```
</details>

### 题目 10.9
创建一个存储过程 sp_AdjustInventory，调整产品库存（增加或减少）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_AdjustInventory
    @ProductID INT,
    @AdjustQty INT,  -- 正数增加，负数减少
    @Reason NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('产品不存在', 16, 1);
        RETURN;
    END;

    UPDATE Products
    SET StockQuantity = StockQuantity + @AdjustQty
    WHERE ProductID = @ProductID;

    SELECT 1 AS Success, '库存调整成功' AS Message;
END;
```
</details>

### 题目 10.10
创建一个存储过程 sp_GetCustomerRanking，返回客户消费排名（前N名）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetCustomerRanking
    @TopN INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        c.CustomerID,
        c.CustomerName,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSpent,
        RANK() OVER (ORDER BY ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) DESC) AS Rank
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CustomerName
    ORDER BY TotalSpent DESC;
END;

-- 执行
EXEC sp_GetCustomerRanking @TopN = 5;
```
</details>

---

## 第十一章：函数与触发器（6题）

### 题目 11.1
创建一个标量函数 fn_GetAge，根据出生日期计算年龄。

<details>
<summary>参考答案</summary>

```sql
CREATE FUNCTION fn_GetAge(@BirthDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE()) -
        CASE WHEN MONTH(@BirthDate) > MONTH(GETDATE())
                  OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
             THEN 1 ELSE 0
        END;
END;

-- 使用
SELECT EmployeeName, dbo.fn_GetAge(BirthDate) AS Age FROM Employees;
```
</details>

### 题目 11.2
创建一个表值函数 fn_GetOrdersByDateRange，返回指定日期范围内的订单。

<details>
<summary>参考答案</summary>

```sql
CREATE FUNCTION fn_GetOrdersByDateRange(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        c.CustomerName,
        o.OrderAmount,
        o.Status
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
);

-- 使用
SELECT * FROM dbo.fn_GetOrdersByDateRange('2024-01-01', '2024-01-31');
```
</details>

### 题目 11.3
创建一个触发器 tr_Orders_LogInsert，在插入订单时记录日志到 OrderLog 表。

<details>
<summary>参考答案</summary>

```sql
-- 先创建日志表
CREATE TABLE OrderLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    Action VARCHAR(20),
    ActionTime DATETIME DEFAULT GETDATE(),
    ActionBy VARCHAR(50) DEFAULT SYSTEM_USER
);

-- 创建触发器
CREATE TRIGGER tr_Orders_LogInsert
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrderLog (OrderID, Action)
    SELECT OrderID, 'INSERT' FROM inserted;
END;
```
</details>

### 题目 11.4
创建一个触发器 tr_Products_UpdateTimestamp，在更新产品时自动更新修改时间。

<details>
<summary>参考答案</summary>

```sql
CREATE TRIGGER tr_Products_UpdateTimestamp
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1 RETURN;

    UPDATE Products
    SET CreatedDate = GETDATE()
    WHERE ProductID IN (SELECT ProductID FROM inserted);
END;
```
</details>

### 题目 11.5
创建一个函数 fn_GetCategorySales，返回指定分类的销售总额。

<details>
<summary>参考答案</summary>

```sql
CREATE FUNCTION fn_GetCategorySales(@CategoryID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT @Total = ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0)
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    WHERE p.CategoryID = @CategoryID;

    RETURN @Total;
END;

-- 使用
SELECT CategoryName, dbo.fn_GetCategorySales(CategoryID) AS Sales FROM Categories;
```
</details>

### 题目 11.6
创建一个触发器 tr_Employees_PreventDelete，阻止删除在职员工。

<details>
<summary>参考答案</summary>

```sql
CREATE TRIGGER tr_Employees_PreventDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted WHERE IsActive = 1)
    BEGIN
        RAISERROR('不能删除在职员工，请先将其标记为离职', 16, 1);
        RETURN;
    END;

    DELETE e FROM Employees e
    JOIN deleted d ON e.EmployeeID = d.EmployeeID;
END;
```
</details>

---

## 第十二章：事务与并发控制（5题）

### 题目 12.1
编写一个事务，同时更新两个员工的薪资（一个加 1000，一个减 1000）。

<details>
<summary>参考答案</summary>

```sql
BEGIN TRANSACTION;

UPDATE Employees SET Salary = Salary + 1000 WHERE EmployeeID = 1;
UPDATE Employees SET Salary = Salary - 1000 WHERE EmployeeID = 2;

-- 检查是否有问题
IF @@ERROR <> 0
    ROLLBACK TRANSACTION;
ELSE
    COMMIT TRANSACTION;
```
</details>

### 题目 12.2
使用 TRY-CATCH 改写上述事务，添加错误处理。

<details>
<summary>参考答案</summary>

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Employees SET Salary = Salary + 1000 WHERE EmployeeID = 1;
    UPDATE Employees SET Salary = Salary - 1000 WHERE EmployeeID = 2;

    COMMIT TRANSACTION;
    PRINT '事务提交成功';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '发生错误: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
```
</details>

### 题目 12.3
创建一个存储过程 sp_TransferEmployee，将员工从一个部门调到另一个部门（带事务）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_TransferEmployee
    @EmployeeID INT,
    @NewDepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 检查员工是否存在
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('员工不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 检查部门是否存在
        IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentID = @NewDepartmentID)
        BEGIN
            RAISERROR('部门不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 执行调动
        UPDATE Employees
        SET DepartmentID = @NewDepartmentID,
            ModifiedDate = GETDATE()
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, '员工调动成功' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```
</details>

### 题目 12.4
演示使用不同隔离级别查询数据。

<details>
<summary>参考答案</summary>

```sql
-- 设置隔离级别为读已提交（默认）
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT * FROM Orders WHERE OrderID = 1;

-- 设置隔离级别为可重复读
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;
SELECT * FROM Orders WHERE CustomerID = 1;
-- 在事务内重复查询将得到相同结果
COMMIT TRANSACTION;

-- 恢复默认
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```
</details>

### 题目 12.5
创建一个存储过程 sp_PlaceOrder，包含完整的下订单逻辑（检查库存、扣减库存、创建订单）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_PlaceOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. 检查库存
        DECLARE @Stock INT;
        SELECT @Stock = StockQuantity FROM Products WITH (UPDLOCK, ROWLOCK)
        WHERE ProductID = @ProductID;

        IF @Stock IS NULL
        BEGIN
            RAISERROR('产品不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF @Stock < @Quantity
        BEGIN
            RAISERROR('库存不足', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 2. 扣减库存
        UPDATE Products
        SET StockQuantity = StockQuantity - @Quantity
        WHERE ProductID = @ProductID;

        -- 3. 创建订单
        INSERT INTO Orders (CustomerID, OrderDate, Status)
        VALUES (@CustomerID, GETDATE(), 'Pending');

        SET @NewOrderID = SCOPE_IDENTITY();

        -- 4. 创建订单明细
        DECLARE @UnitPrice DECIMAL(18,2);
        SELECT @UnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID;

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (@NewOrderID, @ProductID, @Quantity, @UnitPrice);

        -- 5. 更新订单金额
        UPDATE Orders
        SET OrderAmount = @Quantity * @UnitPrice
        WHERE OrderID = @NewOrderID;

        COMMIT TRANSACTION;

        SELECT 1 AS Success, '订单创建成功' AS Message, @NewOrderID AS OrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```
</details>

---

## 综合练习题（10题）

### 综合题 1
查询 2024 年第一季度（1-3月）的销售情况，按月份和产品分类统计销售额。

<details>
<summary>参考答案</summary>

```sql
SELECT
    MONTH(o.OrderDate) AS Month,
    c.CategoryName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    SUM(od.Quantity) AS TotalQuantity,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.OrderDate >= '2024-01-01' AND o.OrderDate < '2024-04-01'
GROUP BY MONTH(o.OrderDate), c.CategoryID, c.CategoryName
ORDER BY Month, TotalSales DESC;
```
</details>

### 综合题 2
找出每个城市消费金额最高的客户。

<details>
<summary>参考答案</summary>

```sql
WITH CustomerSpending AS (
    SELECT
        c.City,
        c.CustomerID,
        c.CustomerName,
        ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSpent,
        RANK() OVER (PARTITION BY c.City ORDER BY ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) DESC) AS RankInCity
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.City, c.CustomerID, c.CustomerName
)
SELECT City, CustomerID, CustomerName, TotalSpent
FROM CustomerSpending
WHERE RankInCity = 1;
```
</details>

### 综合题 3
创建视图 vw_MonthlySalesSummary，显示每月的订单数、客户数、产品销量、销售额。

<details>
<summary>参考答案</summary>

```sql
CREATE VIEW vw_MonthlySalesSummary
AS
SELECT
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    COUNT(DISTINCT o.CustomerID) AS CustomerCount,
    SUM(od.Quantity) AS TotalQuantity,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate);
```
</details>

### 综合题 4
创建一个存储过程 sp_GetProductPerformanceReport，返回产品销售表现报表（包含销售额、排名、占比）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_GetProductPerformanceReport
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL SET @StartDate = '1900-01-01';
    IF @EndDate IS NULL SET @EndDate = GETDATE();

    WITH ProductStats AS (
        SELECT
            p.ProductID,
            p.ProductName,
            c.CategoryName,
            ISNULL(SUM(od.Quantity), 0) AS TotalSold,
            ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSales
        FROM Products p
        JOIN Categories c ON p.CategoryID = c.CategoryID
        LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
        LEFT JOIN Orders o ON od.OrderID = o.OrderID AND o.OrderDate BETWEEN @StartDate AND @EndDate
        WHERE p.IsActive = 1
        GROUP BY p.ProductID, p.ProductName, c.CategoryName
    ),
    TotalStats AS (
        SELECT SUM(TotalSales) AS GrandTotal FROM ProductStats
    )
    SELECT
        ps.ProductID,
        ps.ProductName,
        ps.CategoryName,
        ps.TotalSold,
        ps.TotalSales,
        RANK() OVER (ORDER BY ps.TotalSales DESC) AS SalesRank,
        RANK() OVER (PARTITION BY ps.CategoryName ORDER BY ps.TotalSales DESC) AS CategoryRank,
        CASE WHEN ts.GrandTotal = 0 THEN 0
             ELSE ROUND(ps.TotalSales * 100.0 / ts.GrandTotal, 2)
        END AS SalesPercentage
    FROM ProductStats ps
    CROSS JOIN TotalStats ts
    ORDER BY ps.TotalSales DESC;
END;
```
</details>

### 综合题 5
编写 SQL 找出连续 3 个月都有订单的客户。

<details>
<summary>参考答案</summary>

```sql
WITH MonthlyOrders AS (
    SELECT DISTINCT
        CustomerID,
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        YEAR(OrderDate) * 12 + MONTH(OrderDate) AS MonthSeq
    FROM Orders
),
ConsecutiveMonths AS (
    SELECT
        CustomerID,
        MonthSeq,
        MonthSeq - ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY MonthSeq) AS GroupID
    FROM MonthlyOrders
),
ConsecutiveGroups AS (
    SELECT
        CustomerID,
        COUNT(*) AS ConsecutiveCount
    FROM ConsecutiveMonths
    GROUP BY CustomerID, GroupID
    HAVING COUNT(*) >= 3
)
SELECT DISTINCT c.CustomerID, cu.CustomerName
FROM ConsecutiveGroups c
JOIN Customers cu ON c.CustomerID = cu.CustomerID;
```
</details>

### 综合题 6
创建一个完整的库存管理存储过程，支持入库、出库、盘点三种操作。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_InventoryManagement
    @Operation VARCHAR(20),  -- 'IN', 'OUT', 'ADJUST'
    @ProductID INT,
    @Quantity INT,
    @ReferenceNo VARCHAR(50) = NULL,
    @Remark NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 验证产品
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            RAISERROR('产品不存在', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        DECLARE @CurrentStock INT;
        SELECT @CurrentStock = StockQuantity FROM Products WITH (UPDLOCK, ROWLOCK)
        WHERE ProductID = @ProductID;

        -- 根据操作类型处理
        IF @Operation = 'IN'
        BEGIN
            UPDATE Products SET StockQuantity = StockQuantity + @Quantity
            WHERE ProductID = @ProductID;
        END
        ELSE IF @Operation = 'OUT'
        BEGIN
            IF @CurrentStock < @Quantity
            BEGIN
                RAISERROR('库存不足', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
            UPDATE Products SET StockQuantity = StockQuantity - @Quantity
            WHERE ProductID = @ProductID;
        END
        ELSE IF @Operation = 'ADJUST'
        BEGIN
            UPDATE Products SET StockQuantity = @Quantity
            WHERE ProductID = @ProductID;
        END
        ELSE
        BEGIN
            RAISERROR('无效的操作类型', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 记录库存日志（假设有 InventoryLog 表）
        -- INSERT INTO InventoryLog (...) VALUES (...);

        COMMIT TRANSACTION;

        SELECT 1 AS Success, '操作成功' AS Message,
               (SELECT StockQuantity FROM Products WHERE ProductID = @ProductID) AS CurrentStock;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH;
END;
```
</details>

### 综合题 7
使用递归 CTE 查询组织架构中每个员工的层级和路径。

<details>
<summary>参考答案</summary>

```sql
-- 假设有组织架构表 OrgStructure
-- EmployeeID, EmployeeName, ManagerID

WITH OrgHierarchy AS (
    -- 顶级管理层
    SELECT
        EmployeeID,
        EmployeeName,
        ManagerID,
        1 AS Level,
        CAST(EmployeeName AS NVARCHAR(MAX)) AS Path
    FROM OrgStructure
    WHERE ManagerID IS NULL

    UNION ALL

    -- 递归下属
    SELECT
        e.EmployeeID,
        e.EmployeeName,
        e.ManagerID,
        oh.Level + 1,
        oh.Path + ' -> ' + e.EmployeeName
    FROM OrgStructure e
    JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT
    EmployeeID,
    EmployeeName,
    Level,
    REPLICATE('  ', Level - 1) + EmployeeName AS DisplayName,
    Path
FROM OrgHierarchy
ORDER BY Path;
```
</details>

### 综合题 8
创建一个触发器，在修改订单状态时自动记录变更历史。

<details>
<summary>参考答案</summary>

```sql
-- 创建状态变更历史表
CREATE TABLE OrderStatusHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    ChangedBy VARCHAR(50),
    ChangedDate DATETIME DEFAULT GETDATE()
);

-- 创建触发器
CREATE TRIGGER tr_Orders_StatusHistory
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        INSERT INTO OrderStatusHistory (OrderID, OldStatus, NewStatus, ChangedBy)
        SELECT
            i.OrderID,
            d.Status,
            i.Status,
            SYSTEM_USER
        FROM inserted i
        JOIN deleted d ON i.OrderID = d.OrderID
        WHERE i.Status <> d.Status;
    END;
END;
```
</details>

### 综合题 9
编写 SQL 生成客户流失预警报表（最近 6 个月无订单的客户）。

<details>
<summary>参考答案</summary>

```sql
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    c.RegisterDate,
    MAX(o.OrderDate) AS LastOrderDate,
    DATEDIFF(MONTH, MAX(o.OrderDate), GETDATE()) AS MonthsSinceLastOrder,
    ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CustomerName, c.City, c.RegisterDate
HAVING MAX(o.OrderDate) < DATEADD(MONTH, -6, GETDATE())
    OR MAX(o.OrderDate) IS NULL
ORDER BY TotalSpent DESC;
```
</details>

### 综合题 10
设计并实现一个完整的存储过程，支持按多种条件组合查询订单（客户名、日期范围、状态、产品名）。

<details>
<summary>参考答案</summary>

```sql
CREATE PROCEDURE sp_SearchOrders
    @CustomerName NVARCHAR(100) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Status VARCHAR(20) = NULL,
    @ProductName NVARCHAR(100) = NULL,
    @PageIndex INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @CountSQL NVARCHAR(MAX);
    DECLARE @Params NVARCHAR(MAX);

    SET @Params = N'@CustomerName NVARCHAR(100), @StartDate DATE, @EndDate DATE, @Status VARCHAR(20), @ProductName NVARCHAR(100)';

    -- 构建基础查询
    SET @SQL = N'
    WITH OrderData AS (
        SELECT DISTINCT
            o.OrderID,
            o.OrderDate,
            c.CustomerName,
            o.Status,
            o.OrderAmount,
            ROW_NUMBER() OVER (ORDER BY o.OrderDate DESC) AS RowNum
        FROM Orders o
        JOIN Customers c ON o.CustomerID = c.CustomerID
        LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
        LEFT JOIN Products p ON od.ProductID = p.ProductID
        WHERE 1=1';

    -- 动态添加条件
    IF @CustomerName IS NOT NULL
        SET @SQL = @SQL + N' AND c.CustomerName LIKE @CustomerName + ''%''';

    IF @StartDate IS NOT NULL
        SET @SQL = @SQL + N' AND o.OrderDate >= @StartDate';

    IF @EndDate IS NOT NULL
        SET @SQL = @SQL + N' AND o.OrderDate < DATEADD(DAY, 1, @EndDate)';

    IF @Status IS NOT NULL
        SET @SQL = @SQL + N' AND o.Status = @Status';

    IF @ProductName IS NOT NULL
        SET @SQL = @SQL + N' AND p.ProductName LIKE @ProductName + ''%''';

    SET @SQL = @SQL + N'
    )
    SELECT * FROM OrderData
    WHERE RowNum BETWEEN (@PageIndex - 1) * @PageSize + 1 AND @PageIndex * @PageSize
    ORDER BY OrderDate DESC';

    -- 执行查询
    EXEC sp_executesql @SQL, @Params,
        @CustomerName = @CustomerName,
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @Status = @Status,
        @ProductName = @ProductName;
END;

-- 执行示例
EXEC sp_SearchOrders
    @CustomerName = '北京',
    @StartDate = '2024-01-01',
    @Status = 'Completed',
    @PageIndex = 1,
    @PageSize = 10;
```
</details>

---

**练习题完成！建议完成所有题目后，尝试不看参考答案独立完成综合练习题。**
