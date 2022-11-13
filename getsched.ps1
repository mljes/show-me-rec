function GetLocationIdsByRegion($regionName, $regionDict) {
    return $regionDict[$regionName].Id
}

function GenerateFacilityLocationIdStringByRegion($regionName, $regionDict) {
    $locationIdString = ""
    GetLocationIdsByRegion $regionName $regionDict | ForEach-Object {
        $locationIdString = $locationIdString + "FacilityLocationIdList=$_&"
    }

    return $locationIdString
}

$DateFrom = "2022-11-13T13%3A52"
$DateTo = "2022-11-13T23%3A59"

$regionsUri = "https://recreation.halifax.ca/enterprise/filteredlocationhierarchy"

$regions = @{}
$regionData = Invoke-RestMethod -Method Get -Uri $regionsUri

foreach ($region in $regionData) {
    $regions[$region.Name] = $region.Children
}

# $regions
# $regions["HRM"]

$locationIdString = GenerateFacilityLocationIdStringByRegion "HRM" $regions
$url = "https://recreation.halifax.ca/enterprise/Timetable/GetClassTimeTable?$locationIdString&DateFrom=$DateFrom&DateTo=$DateTo"

class ActivityInfo {
    $FacilityName;
    $ActivityName;
    $StartDatetime;
    $AvailableSlots;
    $Duration;
    $AgeStart;
    $AgeEnd;
    $RestrictedGenderId;
}

$activityList = New-Object Collections.Generic.List[ActivityInfo]
(Invoke-RestMethod -Method Get -Uri $url).Results | Foreach-Object {
    $activityInfo = [ActivityInfo]::new()

    $activityInfo.FacilityName = $_.FacilityName
    $activityInfo.ActivityName = $_.ActivityName
    $activityInfo.StartDatetime = $_.StartDatetime
    $activityInfo.AvailableSlots = "$($_.AvailableSlots)/$($_.Capacity)"
    $activityInfo.AgeEnd = $_.AgeEnd -eq -1 ? "" : "$($_.AgeEnd) months"
    $activityInfo.AgeStart = $_.AgeStart -eq -1 ? "" : "$($_.AgeStart) months"
    $activityInfo.Duration = $_.Duration
    $activityInfo.RestrictedGenderId = $_.RestrictedGenderId

    $activityList.Add($activityInfo)
}

$activityList

