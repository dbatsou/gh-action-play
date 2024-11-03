
DECLARE @maxid INT;

SELECT @maxid = ISNULL(MAX([FeatureSwitchId]),0)
FROM [Config].[FeatureSwitches];

MERGE INTO [Config].[FeatureSwitches] AS Target
    USING (VALUES
    (@maxid + 30, N'Switch5', 0, 1, 'XXXXX','TeamV'),
    (@maxid + 30, N'Switch5', 0, 1, 'XXXXX','TeamV'),
    (@maxid + 30, N'Switch5', 0, 1, 'XXXXX','TeamV'),
    (@maxid + 30, N'Switch5', 0, 1, 'XXXXX','TeamV'),
)   AS Source ([FeatureSwitchId], [Name], [IsEnabled], [NhVersion], [Description], [CategoryName])
    ON Target.Name = Source.Name
    WHEN MATCHED THEN
UPDATE SET [Description] = Source.Description, [CategoryName] = Source.CategoryName
    WHEN NOT MATCHED BY TARGET THEN
INSERT ([FeatureSwitchId], [Name], [IsEnabled], [NhVersion], [Description], [CategoryName])
VALUES ([FeatureSwitchId], [Name], [IsEnabled], [NhVersion], [Description], [CategoryName])
    WHEN NOT MATCHED BY SOURCE THEN DELETE;

UPDATE Config.FeatureSwitches set IsEnabled = (
    SELECT IIF(
                       SUM(CAST(IsEnabled as int)) > 0
               ,1,0)
    FROM Config.FeatureSwitches fs
    WHERE CategoryName = 'Feature Team - Accounting Date'
)
WHERE [Name] = 'XXXXXXX';
--