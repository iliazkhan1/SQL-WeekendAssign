--#################################################################################################################
-- Lab Activity 1: Ranking Functions
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50),
    Salary INT
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'John', 'Doe', 'HR', 50000),
(2, 'Jane', 'Smith', 'HR', 60000),
(3, 'Alice', 'Johnson', 'IT', 70000),
(4, 'Bob', 'Brown', 'IT', 70000),
(5, 'Charlie', 'Davis', 'IT', 60000),
(6, 'Diana', 'Clark', 'Finance', 80000),
(7, 'Evan', 'Lopez', 'Finance', 80000),
(8, 'Fiona', 'Martinez', 'Finance', 75000);

SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DenseSalaryRank,
    ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNumberGlobal
FROM Employees;


--##########################################################################################################
--Lab Activity 2: Subqueries
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    SalespersonID INT,
    Region NVARCHAR(50),
    TotalSales INT
);

INSERT INTO Sales (SaleID, SalespersonID, Region, TotalSales) VALUES
(1, 101, 'North', 50000),
(2, 102, 'North', 60000),
(3, 103, 'South', 40000),
(4, 104, 'South', 55000),
(5, 105, 'East', 70000),
(6, 106, 'East', 65000),
(7, 107, 'West', 60000),
(8, 108, 'West', 50000);

SELECT 
    SaleID,
    SalespersonID,
    Region,
    TotalSales
FROM Sales S1
WHERE TotalSales > (
    SELECT AVG(TotalSales)
    FROM Sales S2
    WHERE S2.Region = S1.Region
);

SELECT 
    SaleID,
    SalespersonID,
    Region,
    TotalSales,
    (
        SELECT COUNT(*) + 1
        FROM Sales S2
        WHERE S2.Region = S1.Region AND S2.TotalSales > S1.TotalSales
    ) AS SalesRank
FROM Sales S1;



--##########################################################################################################
--Lab Activity 3: Stored Procedures
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50),
    Salary INT
);
GO


INSERT INTO Employee (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'John', 'Doe', 'HR', 50000),
(2, 'Jane', 'Smith', 'HR', 60000),
(3, 'Alice', 'Johnson', 'IT', 70000),
(4, 'Bob', 'Brown', 'IT', 75000),
(5, 'Charlie', 'Davis', 'Finance', 80000),
(6, 'Diana', 'Clark', 'Finance', 85000);
GO

CREATE PROCEDURE GetHighEarningEmployees
    @SalaryThreshold INT
AS
BEGIN
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary
    FROM Employee
    WHERE Salary > @SalaryThreshold;
END;
GO

CREATE PROCEDURE UpdateEmployeeSalary
    @DepartmentName NVARCHAR(50),
    @IncrementAmount INT
AS
BEGIN
    UPDATE Employee
    SET Salary = Salary + @IncrementAmount
    WHERE Department = @DepartmentName;
END;
GO

EXEC GetHighEarningEmployees @SalaryThreshold = 60000;
GO


EXEC UpdateEmployeeSalary @DepartmentName = 'HR', @IncrementAmount = 5000;
GO

SELECT * FROM Employee;
GO



--####################################################################################################################
--Lab Activity 4: LAG Function
CREATE TABLE MonthlySales (
    Month NVARCHAR(20),
    Region NVARCHAR(50),
    TotalSales INT
);
GO

INSERT INTO MonthlySales (Month, Region, TotalSales) VALUES
('January', 'North', 50000),
('February', 'North', 48000),
('March', 'North', 52000),
('January', 'South', 45000),
('February', 'South', 47000),
('March', 'South', 46000);
GO

SELECT 
    Month,
    Region,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Region ORDER BY 
        CASE Month
            WHEN 'January' THEN 1
            WHEN 'February' THEN 2
            WHEN 'March' THEN 3
            WHEN 'April' THEN 4
            WHEN 'May' THEN 5
            WHEN 'June' THEN 6
            WHEN 'July' THEN 7
            WHEN 'August' THEN 8
            WHEN 'September' THEN 9
            WHEN 'October' THEN 10
            WHEN 'November' THEN 11
            WHEN 'December' THEN 12
        END
    ) AS PreviousMonthSales,
    (TotalSales - 
        LAG(TotalSales) OVER (PARTITION BY Region ORDER BY 
            CASE Month
                WHEN 'January' THEN 1
                WHEN 'February' THEN 2
                WHEN 'March' THEN 3
                WHEN 'April' THEN 4
                WHEN 'May' THEN 5
                WHEN 'June' THEN 6
                WHEN 'July' THEN 7
                WHEN 'August' THEN 8
                WHEN 'September' THEN 9
                WHEN 'October' THEN 10
                WHEN 'November' THEN 11
                WHEN 'December' THEN 12
            END
        )
    ) AS SalesDifference,
    CASE
        WHEN TotalSales < LAG(TotalSales) OVER (PARTITION BY Region ORDER BY 
            CASE Month
                WHEN 'January' THEN 1
                WHEN 'February' THEN 2
                WHEN 'March' THEN 3
                WHEN 'April' THEN 4
                WHEN 'May' THEN 5
                WHEN 'June' THEN 6
                WHEN 'July' THEN 7
                WHEN 'August' THEN 8
                WHEN 'September' THEN 9
                WHEN 'October' THEN 10
                WHEN 'November' THEN 11
                WHEN 'December' THEN 12
            END
        ) THEN 'Decrease'
        ELSE 'No Decrease'
    END AS SalesTrend
FROM MonthlySales;
GO


--##################################################################################################################
--Lab Activity 5: LEAD Function
SELECT 
    Month,
    Region,
    TotalSales,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS NextMonthSales,
    (LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) - TotalSales) AS SalesChangeNextMonth,
    CASE
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) > TotalSales THEN 'Increase Expected'
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) < TotalSales THEN 'Decrease Expected'
        ELSE 'No Change'
    END AS PredictedTrend
FROM MonthlySales;
GO
