Configuration TimeZone_SetTimeZone_Config
{
    Import-DSCResource -ModuleName ComputerManagementDsc

    Node localhost
    {
        TimeZone TimeZoneExample
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'Romance Standard Time'
        }
    }
}
