
Select c1.Impressions,c1.Clicks,c1.Spend,
c2.Event_Registration,c2.Applications
Into Campaign_Conversion
From dbo.Campaigns As c1
 join dbo. Conversions As c2
On c1.date=c2.Date
and  c2.Channel=c1.Channel
 and c1.Media_Partner=c2.Media_Partner
and c1.program=c2.Program;

select * from Campaign_Conversion;

ALTER TABLE Campaign_Conversion
  add Campaign_ID INT IDENTITY (1,1) NOT NULL;

alter table Campaign_Conversion 
add Total_Conversion as(Event_Registration+Applications);

 alter table Campaign_Conversion
 add CTR as round(Clicks/nullif(Impressions,0),2);


 alter table Campaign_Conversion
 add CPL as round((Event_Registration+Applications),2)/ nullif(Spend,0);

alter table Campaign_Conversion
add CPC as round(Spend/nullif(Clicks,0),2);

select * from Campaign_Conversion;

ALTER TABLE dbo.Campaigns
  add Campaign_ID INT IDENTITY (1,1) NOT NULL;
  
  select * from dbo.Campaigns;

  ALTER TABLE Conversions
  add Campaign_ID INT IDENTITY (1,1) NOT NULL;

  select * from dbo.Conversions;