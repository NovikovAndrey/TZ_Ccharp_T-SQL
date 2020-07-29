select C.ClientName, COUNT(*) as KolAccounts, MIN(CA.DateOpening) as FirstEntry from Clients C
join CustomerAccounts CA on CA.ClientId=C.Id group by C.ClientName

select C.ClientName, MAX(CA.DateClosing) as LastClosing from Clients C
join CustomerAccounts CA on CA.ClientId=C.Id where C.Id not in (select ClientId from CustomerAccounts where DateClosing is null) group by C.ClientName

select CA.AccountNumber from Clients C
join CustomerAccounts CA on CA.ClientId=C.Id and C.ClientName like N'%ОАО%' order by C.ClientName

update [dbo].[CustomerAccounts] set Balance=0 where ClientId in (select Id from [dbo].[Clients] where contains(ClientName, N'"ОАО*"'))

select C.ClientName, CA.AccountNumber from Clients C
join CustomerAccounts CA on CA.ClientId=C.Id and CA.AccountNumber IS NOT NULL and CA.DateClosing is null order by C.ClientName
