<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>VSP_Premier_Tier_Order_Update</fullName>
        <description>Update the Order # to blank when Status is inactive.</description>
        <field>Order__c</field>
        <name>VSP Premier Tier Order Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>VSP Premier Tier Clear Out Order</fullName>
        <actions>
            <name>VSP_Premier_Tier_Order_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Premier_Tier__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Clears out order #</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
