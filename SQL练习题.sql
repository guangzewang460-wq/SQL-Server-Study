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





--------------------------------   第一章   -----------------------

-- 1.查询当前 SQL Server 的版本信息。
SELECT @@VERSION;

-- 2.查看 SQLExerciseDB 数据库中所有用户表的数量。
select count(*) from Employees

-- 3.查询 Employees 表的列信息，包括列名、数据类型、是否允许为空。
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees'
ORDER BY ORDINAL_POSITION;

-- 4.格式化显示当前日期为 "2024年01月15日" 的格式。
SELECT FORMAT(GETDATE(), 'yyyy年MM月dd日');

-- 5.查询 Employees 表中所有员工，显示：员工姓名、年龄（周岁）、入职年限。
select EmployeeName 员工姓名,DATEDIFF(year,BirthDate,GETDATE()) 年龄,DATEDIFF(year,HireDate,GETDATE()) 入职年限 from Employees