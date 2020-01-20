/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 27-March-2018
* Description: This handler is for LOAReportTeamMember. It handles overrides beforeUpdate and beforeDelete 
*               from hanlder class
* 
*/
public class LOATeamMemberValidation_TrigAct extends TriggerHandler {

    
    /*
    * Fire logic for beforeUpdate
    */
    /**
    * @description: This methods overrides beforeUpdate methods from Hanlder and restricts unchecking of Approver field
    *               when Approval gate has value
    */
    public override void beforeUpdate(TriggerContext context) 
    {
        if (!this.hasRun())
        {
            List<LOAReportTeam__c> loaTeamList = context.newList;
            for( LOAReportTeam__c entity: loaTeamList)
            {
                if( !entity.Approver__c && null != entity.ApprovalGate__c )
                {
                    entity.Approver__c.addError(' Approver cannot be unchecked when Approval Gate has Value ');
                }
            }
            
        }

    }

    /*
    * Fire logic for beforeDelete
    */
    /**
    * @description : This method overrides beforeDelete from handler and doesnt allow team member to be deleted when
    *                 when Approval Gate has value.
    */
    public override void beforeDelete(TriggerContext context) 
    {
        if (!this.hasRun())
        {
            List<LOAReportTeam__c> loaTeamList = context.oldList;
            for( LOAReportTeam__c entity:loaTeamList)
            {
                if (null != entity.ApprovalGate__c )
                {
                    entity.addError(' You cannot delete Team Member When Approver Gate has Value');
                }
            }
            
        }

    }
}