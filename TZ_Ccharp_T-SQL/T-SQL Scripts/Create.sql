CREATE DATABASE ClientsBase
go
USE ClientsBase
CREATE TABLE Clients
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ClientName NVARCHAR(450) NOT NULL,
	ClientAddress NVARCHAR(450)
)
CREATE UNIQUE INDEX ClientName_ClientAddress
ON Clients (ClientName, ClientAddress);
go

CREATE UNIQUE INDEX ClientName
ON Clients (ClientName);
go

CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;  
GO  
CREATE FULLTEXT INDEX ON [dbo].[Clients](ClientName)   
   KEY INDEX ClientName   
   WITH STOPLIST = SYSTEM;  
GO  

CREATE TABLE Currencies
(
	Id TINYINT IDENTITY(1,1) PRIMARY KEY,
	CurrencyName NVARCHAR(10) NOT NULL UNIQUE
)
go

CREATE TABLE CustomerAccounts
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	ClientId INT NOT NULL,
	AccountNumber NVARCHAR(450) NOT NULL UNIQUE,
	AccountCurrency TINYINT NOT NULL,
	DateOpening Date NOT NULL,
	DateClosing DATE,
	Balance DECIMAL(20, 2),
	CONSTRAINT FK_Client_Account FOREIGN KEY (ClientId) REFERENCES Clients(Id) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Account_Currencies FOREIGN KEY (AccountCurrency) REFERENCES Currencies(Id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
go

CREATE TABLE LogClients
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ClientId INT NOT NULL,
	DateOfChange DATETIME DEFAULT(GETDATE()),
	TypeChange NVARCHAR(MAX) NOT NULL,
	OldName NVARCHAR(MAX),
	NewName NVARCHAR(MAX),
	OldAddress NVARCHAR(MAX),
	NewAddress NVARCHAR(MAX)
)
go

CREATE TABLE LogCurrency
(
	Id int IDENTITY(1,1) PRIMARY KEY,
	CurrencyId int NOT NULL,
	DateOfChange DATETIME DEFAULT(GETDATE()),
	TypeChange NVARCHAR(MAX) NOT NULL,
	OldCurrencyName NVARCHAR(MAX),
	NewCurrencyName NVARCHAR(MAX)
)
go

CREATE TABLE LogCustomerAccounts
(
	Id int IDENTITY(1,1) PRIMARY KEY,
	ClientId int NOT NULL,
	AccountNumber NVARCHAR(MAX) NOT NULL,
	DateOfChange DATETIME DEFAULT(GETDATE()),
	TypeChange NVARCHAR(MAX) NOT NULL,
	OldAccountCurrency TINYINT,
	NewAccountCurrency TINYINT,
	OldDateOpening DATE,
	NewDateOpening DATE,
	OldDateClosing DATE,
	NewDateClosing DATE,
	OldBalance DECIMAL(20, 2),
	NewBalance DECIMAL(20, 2)
)
go

CREATE TRIGGER InsertTriggerCustomerAccounts
   ON  [dbo].[CustomerAccounts]
   AFTER INSERT
AS 
BEGIN
	INSERT INTO LogCustomerAccounts (ClientId, AccountNumber, TypeChange, NewAccountCurrency, NewDateOpening, NewDateClosing, NewBalance) 
	SELECT inserted.ClientId, AccountNumber, 'Insert', AccountCurrency, DateOpening, DateClosing, Balance FROM inserted
END
GO

CREATE TRIGGER DeleteTriggerCustomerAccounts
   ON  [dbo].[CustomerAccounts]
   AFTER DELETE
AS 
BEGIN
	INSERT INTO LogCustomerAccounts (ClientId, AccountNumber, TypeChange, OldAccountCurrency, OldDateOpening, OldDateClosing, OldBalance) 
	SELECT deleted.ClientId, AccountNumber, 'Delete', AccountCurrency, DateOpening, DateClosing, Balance  FROM deleted
END
GO

CREATE TRIGGER UpdateTriggerCustomerAccounts
   ON  [dbo].[CustomerAccounts]
   AFTER UPDATE
AS 
BEGIN
	INSERT INTO LogCustomerAccounts (ClientId, AccountNumber, TypeChange, NewAccountCurrency, OldAccountCurrency, NewDateOpening, OldDateOpening, NewDateClosing, OldDateClosing, NewBalance, OldBalance)
	SELECT inserted.ClientId, inserted.AccountNumber, 'UPDATE', inserted.AccountCurrency, deleted.AccountCurrency, inserted.DateOpening, deleted.DateOpening, inserted.DateClosing, deleted.DateClosing, inserted.Balance, deleted.Balance FROM inserted
	left join deleted on deleted.Id = inserted.Id and deleted.AccountNumber = inserted.AccountNumber
END
GO

CREATE TRIGGER InsertTriggerClient
   ON  [dbo].[Clients]
   AFTER INSERT
AS 
BEGIN
	INSERT INTO LogClients (ClientId, TypeChange, NewName, NewAddress) SELECT Id, 'Insert', ClientName, ClientAddress FROM inserted
END
GO

CREATE TRIGGER DeleteTriggerClient
   ON  [dbo].[Clients]
   AFTER DELETE
AS 
BEGIN
	INSERT INTO LogClients (ClientId, TypeChange, OldName, OldAddress) SELECT Id, 'Delete', ClientName, ClientAddress  FROM deleted
END
GO

CREATE TRIGGER UpdateTriggerClient
   ON  [dbo].[Clients]
   AFTER UPDATE
AS 
BEGIN
	INSERT INTO LogClients ([ClientId], [TypeChange], [OldName], [NewName], [OldAddress], [NewAddress])
	SELECT inserted.Id, 'UPDATE', deleted.ClientName, inserted.ClientName, deleted.ClientAddress, inserted.ClientAddress FROM inserted
	left join deleted on deleted.Id = inserted.Id
END
GO

CREATE TRIGGER InsertTriggerCurrency
   ON  [dbo].[Currencies]
   AFTER INSERT
AS 
BEGIN
	INSERT INTO LogCurrency (CurrencyId, TypeChange, NewCurrencyName) SELECT Id, 'Insert', CurrencyName FROM inserted
END
GO

CREATE TRIGGER DeleteTriggerCurrency
   ON  [dbo].[Currencies]
   AFTER DELETE
AS 
BEGIN
	INSERT INTO LogCurrency (CurrencyId, TypeChange, OldCurrencyName) SELECT Id, 'Delete', CurrencyName  FROM deleted
END
GO

CREATE TRIGGER UpdateTriggerCurrency
   ON  [dbo].[Currencies]
   AFTER UPDATE
AS 
BEGIN
	INSERT INTO LogCurrency (CurrencyId, [TypeChange], [OldCurrencyName], [NewCurrencyName])
	SELECT inserted.Id, 'UPDATE', deleted.CurrencyName, inserted.CurrencyName FROM inserted
	left join deleted on deleted.Id = inserted.Id
END
GO