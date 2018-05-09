PRINT 'Fixing StateProvinces data'

UPDATE [WideWorldImporters].[Application].[StateProvinces]
   SET [StateProvinceName] = 'Massachusetts'
 WHERE [StateProvinceName] = 'Massachusetts[E]'
