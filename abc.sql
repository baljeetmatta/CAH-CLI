USE [QuickRich]
GO
/****** Object:  StoredProcedure [dbo].[BoosterIncome]    Script Date: 14-06-2025 10:16:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--alter table associates add  LeftCount int,RightCount int, LeftPV int, RightPV int ,LeftGreen int,RightGreen int
--alter table associates add LeftBalance int,rightbalance int
ALTER Procedure [dbo].[BoosterIncome] @ACode varchar(50)
as
begin
declare @count int
declare @cursor cursor
declare @AssociateID uniqueidentifier
declare @Leftbalance int
declare @rightbalance int
declare @leftPV int
declare @RightPV int
declare @LeftBalancePV decimal(12,2)
declare @minPV decimal(12,2)
declare @payout decimal(12,2)
declare @AssociateCode varchar(100)
declare @DirectID uniqueidentifier
declare @RightBalancePV decimal(12,2)

declare @CountDirectL int
declare @CountDirectR int

set @cursor=cursor for select AssociateID,LeftBalance,Rightbalance,LeftBalancePV,RightBalancePV from Associates
where (Leftbalance>1500 and Rightbalance>=3000) or (Leftbalance>=3000 and Rightbalance>=1500)
and AssociateId not in (select associateID from payouts where payouttype='First Pair')
open @cursor
fetch next from @cursor into @AssociateID,@Leftbalance,@rightbalance,@leftBalancePV,@RightBalancePV
while @@fetch_status=0
begin
    --BOOSTER INCOME
    select @count=count(*) from payouts where  AssociateID=@AssociateID and payouttype='First Pair'
    if @count=0
    begin
    select @CountDirectL=count(*) from Associates where DirectID=@AssociateID and position=1 and istopup='true'
    select @CountDirectR=count(*) from Associates where DirectID=@AssociateID and position=2 and istopup='true'

    if (@CountDirectL>=2 and @CountDirectR>=1) or (@CountDirectL>=2 and @CountDirectR>=1)
    begin
	
	--select @minPV=dbo.Minimum(@LeftbalancePV,@rightbalancePV)

	 set @payout=@minPV*0.1

        insert into payouts (payoutType,description,AssociateId,Dated,Amount,TDS,Admin,ispaid)
        select 'First Pair','First Pair '+@ACode,@AssociateId,getDate(),@payout,@payout*0.05,@payout*0.05,'false'

		select @AssociateCode=AssociateCode,@DirectID=DirectID from Associates where AssociateID=@AssociateID
  
  set @payout=@payout*0.1
  
  Insert into Payouts (payouttype,description,AssociateID,Dated,Amount,tds,admin,ispaid)
        select 'Arogya Bonus ','Arogya Bonus '+@AssociateCode+'('+convert(varchar,@minPV)+')',@DirectID,DateAdd(MINUTE,30 ,DateAdd(HOUR,5, getutcDate())),@payout,@payout*0.05,@payout*0.05,'false'


        if @leftbalance>=1 and @rightbalance>=2
            begin   
                update associates set Leftbalance=Leftbalance-1,rightbalance=rightbalance-2 where associateID=@AssociateID

            end
    
        else
            begin
                update associates set Leftbalance=Leftbalance-2,rightbalance=rightbalance-1 where associateID=@AssociateID
            end
    end
    end

    fetch next from @cursor into @AssociateID,@LeftBalance,@Rightbalance,@LeftBalancePV,@RightBalancePv
end
close @cursor
deallocate @cursor
exec MatchingIncome @ACode
end

