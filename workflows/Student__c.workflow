<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Student_Status_Field_Update</fullName>
        <field>Status__c</field>
        <literalValue>Fail</literalValue>
        <name>Student Status Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Student Status</fullName>
        <actions>
            <name>Student_Status_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Student__c.Percent_of_Marks__c</field>
            <operation>lessOrEqual</operation>
            <value>35</value>
        </criteriaItems>
        <description>Copado check</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
