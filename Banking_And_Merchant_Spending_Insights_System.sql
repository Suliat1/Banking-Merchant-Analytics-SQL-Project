CREATE DATABASE Banking_And_Merchant_Spending_Insights_System;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    Country VARCHAR(50),
    CreatedDate DATE
);

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(30),
    Balance DECIMAL(15,2),
    DateOpened DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionType VARCHAR(20),
    Amount DECIMAL(15,2),
    TransactionDate DATE,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE Merchants (
    MerchantID INT PRIMARY KEY,
    MerchantName VARCHAR(100),
    Category VARCHAR(50)
);

CREATE TABLE Merchant_Transactions (
    MT_ID INT PRIMARY KEY,
    TransactionID INT,
    MerchantID INT,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID),
    FOREIGN KEY (MerchantID) REFERENCES Merchants(MerchantID)
);

INSERT INTO Customers (CustomerID, FullName, Email, Country, CreatedDate)
VALUES
(1, 'John Doe', 'john.doe@email.com', 'Ivory Coast', '2025-01-10'),
(2, 'Mary Johnson', 'mary.j@email.com', 'Ghana', '2025-02-15'),
(3, 'Sarah Mensah', 'sarah.m@email.com', 'Nigeria', '2025-03-01'),
(4, 'David Owusu', 'david.o@email.com', 'Ghana', '2025-03-10'),
(5, 'Amina Traore', 'amina.t@email.com', 'Mali', '2025-03-12'),
(6, 'Kofi Mensah', 'kofi.m@email.com', 'Ghana', '2025-04-01'),
(7, 'Fatou Diallo', 'fatou.d@email.com', 'Senegal', '2025-04-05'),
(8, 'Jean Kouassi', 'jean.k@email.com', 'Ivory Coast', '2025-04-10');

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, DateOpened)
VALUES
(101, 1, 'Savings', 5000, '2025-01-12'),
(102, 2, 'Current', 12000, '2025-02-18'),
(103, 3, 'Savings', 8000, '2025-03-05'),
(104, 4, 'Savings', 3000, '2025-03-15'),
(105, 5, 'Current', 15000, '2025-03-20'),
(106, 6, 'Savings', 7000, '2025-04-03'),
(107, 7, 'Current', 22000, '2025-04-08'),
(108, 8, 'Savings', 4500, '2025-04-12');

INSERT INTO Transactions (TransactionID, AccountID, TransactionType, Amount, TransactionDate)
VALUES
(1, 101, 'Deposit', 2000, '2025-05-01'),
(2, 101, 'Withdrawal', 1000, '2025-05-02'),
(3, 102, 'Transfer', 3000, '2025-05-03'),
(4, 103, 'Deposit', 1500, '2025-05-04'),
(5, 104, 'Withdrawal', 500, '2025-05-05'),
(6, 105, 'Deposit', 4000, '2025-05-06'),
(7, 106, 'Transfer', 2500, '2025-05-07'),
(8, 107, 'Withdrawal', 3500, '2025-05-08'),
(9, 108, 'Deposit', 1200, '2025-05-09'),
(10, 102, 'Deposit', 5000, '2025-05-10'),
(11, 103, 'Transfer', 2000, '2025-05-11'),
(12, 101, 'Deposit', 3000, '2025-05-12');

INSERT INTO Merchants (MerchantID, MerchantName, Category)
VALUES
(1, 'Amazon', 'E-commerce'),
(2, 'Uber', 'Transport'),
(3, 'Netflix', 'Entertainment'),
(4, 'Jumia', 'E-commerce'),
(5, 'Total Gas', 'Energy'),
(6, 'Spotify', 'Music');

INSERT INTO Merchant_Transactions (MT_ID, TransactionID, MerchantID)
VALUES
(1, 1, 1),
(2, 3, 2),
(3, 4, 4),
(4, 6, 1),
(5, 7, 5),
(6, 8, 2),
(7, 9, 3),
(8, 10, 1),
(9, 11, 4),
(10, 12, 6);

--Customer Analysis
--S1 \ Who are the top 5 customers by total balance?
SELECT TOP 5 
C.CustomerID, C.FullName ,SUM(A.Balance) as Total_Balance
FROM Customers C JOIN Accounts A
ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID , C.FullName
ORDER BY Total_Balance DESC;

--S2 \ Which customers make the most transactions?
SELECT TOP 1 C.CustomerID, C.FullName, COUNT(T.TransactionID) as Total_Transaction 
FROM Transactions T JOIN Accounts A
ON T.AccountID = A.AccountID 
JOIN Customers C
ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.FullName
ORDER BY Total_Transaction DESC;

-- S3 \ Which country has the highest number of customers?

SELECT TOP 1 Country,COUNT(CustomerID) as Country_max_customers
FROM Customers 
GROUP BY Country
ORDER BY Country_max_customers DESC;

--S4 Which customers have never made a transaction?
SELECT C.CustomerID, C.FullName,COUNT(T.TransactionID) as Total_Transaction 
FROM Customers C
LEFT JOIN Accounts A 
    ON C.CustomerID = A.CustomerID
LEFT JOIN Transactions T 
    ON T.AccountID = A.AccountID
GROUP BY C.CustomerID, C.FullName
HAVING COUNT(T.TransactionID) = 0;

--S5 Spending & Revenue
--Which merchants generate the highest total spending?
 SELECT TOP 1  M.MerchantID ,M.MerchantName, 
SUM(T.Amount) as Total_spending 
FROM Transactions T
JOIN Merchant_Transactions MT
ON T.TransactionID =MT.TransactionID
JOIN Merchants M
ON M.MerchantID =MT.MerchantID
GROUP BY M.MerchantID ,M.MerchantName
ORDER BY Total_spending DESC;

--S6 What is the total revenue per merchant category?
SELECT M.Category , SUM(T.Amount) as Total_revenue
FROM Merchants M
JOIN Merchant_Transactions MT
ON M.MerchantID =MT.MerchantID
JOIN Transactions T
ON T.TransactionID = MT.TransactionID
GROUP BY Category;
--S7 Which customers spend the most money at merchants?
SELECT TOP 1 C.CustomerID, C.FullName,C.Country, SUM(T.Amount) as Top_customer_spending_at_merchants
FROM Customers C
JOIN Accounts A ON C.CustomerID =A.CustomerID
JOIN Transactions T ON T.AccountID = A.AccountID
JOIN Merchant_Transactions MT ON 
MT.TransactionID = T.TransactionID

GROUP BY C.CustomerID, C.FullName,C.Country
ORDER BY SUM(T.Amount) DESC;

--S8 Which month has the highest total transaction value?
SELECT TOP 1 MONTH(TransactionDate) as Month,YEAR(TransactionDate) as Year, SUM(Amount) AS highest_total_transaction
FROM Transactions 
GROUP BY MONTH(TransactionDate),
YEAR(TransactionDate)
ORDER BY SUM(Amount) DESC;

-- S9 Total Revenue (Overall Money Flow)
SELECT SUM(Amount) AS Total_Revenue
FROM Transactions;

--S10 TOTAL CUSTOMERS
SELECT COUNT(CustomerID) AS Total_Customers
FROM Customers;

-- S11 TOTAL TRANSACTIONS 
SELECT COUNT(TransactionID) AS Total_Transactions
FROM Transactions;

--TOP CUSTOMERS BY SPENDING 
SELECT TOP 1 
    C.CustomerID,
    C.FullName,
    SUM(T.Amount) AS Total_Spent
FROM Customers C
JOIN Accounts A ON C.CustomerID = A.CustomerID
JOIN Transactions T ON T.AccountID = A.AccountID
GROUP BY C.CustomerID, C.FullName
ORDER BY Total_Spent DESC;