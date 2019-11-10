<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>VSPR28_Update_QA_Review_Status_Closed</fullName>
        <field>QA_Review_Status__c</field>
        <literalValue>Closed - Non-responder</literalValue>
        <name>VSPR28 Update QA Review Status Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>VSPR28_QA Review Status 45 Days No Response</fullName>
        <active>true</active>
        <formula>NOT(ISBLANK(Original_DocuSign_Sent_Date__c))  		 		&amp;&amp; 		 		ISBLANK(DocuSign_Completion_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>VSPR28_Update_QA_Review_Status_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>45</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
