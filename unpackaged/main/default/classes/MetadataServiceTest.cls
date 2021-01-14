/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
 **/
@isTest
private class MetadataServiceTest
{
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
                Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType)
        {
            if(request instanceof Framework.MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            /*
        else if(request instanceof MetadataService.checkDeployStatus_element)
            response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
        else if(request instanceof MetadataService.listMetadata_element)
            response.put('response_x', new MetadataService.listMetadataResponse_element());
        else if(request instanceof MetadataService.checkRetrieveStatus_element)
            response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
        else if(request instanceof MetadataService.describeMetadata_element)
            response.put('response_x', new MetadataService.describeMetadataResponse_element());
        else if(request instanceof MetadataService.deploy_element)
            response.put('response_x', new MetadataService.deployResponse_element());
        else if(request instanceof MetadataService.updateMetadata_element)
            response.put('response_x', new MetadataService.updateMetadataResponse_element());
        else if(request instanceof MetadataService.renameMetadata_element)
            response.put('response_x', new MetadataService.renameMetadataResponse_element());
        else if(request instanceof  MetadataService.cancelDeploy_element)
            response.put('response_x', new MetadataService.cancelDeployResponse_element());
        else if(request instanceof  MetadataService.deleteMetadata_element)
            response.put('response_x', new MetadataService.deleteMetadataResponse_element());
        else if(request instanceof  MetadataService.upsertMetadata_element)
            response.put('response_x', new MetadataService.upsertMetadataResponse_element());
        else if(request instanceof  MetadataService.createMetadata_element)
            response.put('response_x', new MetadataService.createMetadataResponse_element());
        else if(request instanceof  MetadataService.deployRecentValidation_element)
            response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
        else if(request instanceof MetadataService.describeValueType_element)
            response.put('response_x', new MetadataService.describeValueTypeResponse_element());
        else if(request instanceof MetadataService.checkRetrieveStatus_element)
            response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());

             */
            return;
        }
    }

    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        Test.startTest();
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        Test.startTest();
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        /*
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);

         */
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        Test.startTest();
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        /*
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);

         */
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeTypes()
    {
        // Reference types
        Test.startTest();
        new MetadataService();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.LogInfo();
        new MetadataService.CallOptions_element();
        new MetadataService.AsyncResult();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.Metadata();
        new MetadataService.SessionHeader_element();
        new MetadataService.PackageTypeMembers();
        new MetadataService.RemoteSiteSetting();
        new MetadataService.retrieveResponse_element();
        new MetadataService.DebuggingInfo_element();

        new MetadataService.checkStatus_element();
        new MetadataService.checkStatusResponse_element();
        new MetadataService.create_element();
        new MetadataService.createResponse_element();
        Test.stopTest();
    }

    /*
    @IsTest
    private static void elfMissingGetRecordsTest() { // elf patch
        Test.startTest();
        new MetadataService.ReadFlowResult().getRecords();
        new MetadataService.ReadWorkflowResult().getRecords();
        new MetadataService.ReadWorkflowRuleResult().getRecords();
        new MetadataService.ReadAssignmentRulesResult().getRecords();
        new MetadataService.ReadAssignmentRuleResult().getRecords();
        new MetadataService.ReadAutoResponseRulesResult().getRecords();
        new MetadataService.ReadAutoResponseRuleResult().getRecords();
        new MetadataService.ReadEscalationRulesResult().getRecords();
        new MetadataService.ReadEscalationRuleResult().getRecords();
        new MetadataService.ReadPostTemplateResult().getRecords();
        new MetadataService.ReadApprovalProcessResult().getRecords();
        new MetadataService.ReadHomePageComponentResult().getRecords();
        new MetadataService.ReadHomePageLayoutResult().getRecords();
        new MetadataService.ReadCustomObjectTranslationResult().getRecords();
        new MetadataService.ReadTranslationsResult().getRecords();
        new MetadataService.ReadProfileResult().getRecords();
        new MetadataService.ReadPermissionSetResult().getRecords();
        new MetadataService.ReadDataCategoryGroupResult().getRecords();
        new MetadataService.ReadRemoteSiteSettingResult().getRecords();
        new MetadataService.ReadPackageResult().getRecords();
        new MetadataService.ReadAuthProviderResult().getRecords();
        new MetadataService.ReadKnowledgeSettingsResult().getRecords();
        new MetadataService.ReadSharingSetResult().getRecords();
        new MetadataService.ReadSecuritySettingsResult().getRecords();
        new MetadataService.ReadIdeasSettingsResult().getRecords();
        new MetadataService.ReadChatterAnswersSettingsResult().getRecords();
        new MetadataService.ReadCommunityResult().getRecords();
        new MetadataService.ReadActivitiesSettingsResult().getRecords();
        new MetadataService.ReadContractSettingsResult().getRecords();
        new MetadataService.ReadOrderSettingsResult().getRecords();
        new MetadataService.ReadOpportunitySettingsResult().getRecords();
        new MetadataService.ReadProductSettingsResult().getRecords();
        new MetadataService.ReadQuoteSettingsResult().getRecords();
        new MetadataService.ReadCallCenterResult().getRecords();
        new MetadataService.ReadEntitlementProcessResult().getRecords();
        new MetadataService.ReadMilestoneTypeResult().getRecords();
        new MetadataService.ReadEntitlementTemplateResult().getRecords();
        new MetadataService.ReadEntitlementSettingsResult().getRecords();
        new MetadataService.ReadBusinessHoursSettingsResult().getRecords();
        new MetadataService.ReadBusinessHoursEntryResult().getRecords();
        new MetadataService.ReadConnectedAppResult().getRecords();
        new MetadataService.ReadAppMenuResult().getRecords();
        new MetadataService.ReadMobileSettingsResult().getRecords();
        new MetadataService.ReadNetworkResult().getRecords();
        new MetadataService.ReadCompanySettingsResult().getRecords();
        new MetadataService.ReadForecastingSettingsResult().getRecords();
        new MetadataService.ReadSamlSsoConfigResult().getRecords();
        new MetadataService.ReadLiveAgentSettingsResult().getRecords();
        new MetadataService.ReadSkillResult().getRecords();
        new MetadataService.ReadLiveChatDeploymentResult().getRecords();
        new MetadataService.ReadLiveChatButtonResult().getRecords();
        new MetadataService.ReadLiveChatAgentConfigResult().getRecords();
        new MetadataService.ReadSynonymDictionaryResult().getRecords();
        new MetadataService.ReadFolderResult().getRecords();
        new MetadataService.ReadReportFolderResult().getRecords();
        new MetadataService.ReadDashboardFolderResult().getRecords();
        new MetadataService.ReadDocumentFolderResult().getRecords();
        new MetadataService.ReadEmailFolderResult().getRecords();
        new MetadataService.ReadRoleOrTerritoryResult().getRecords();
        new MetadataService.ReadWorkflowActionResult().getRecords();
        new MetadataService.ReadSiteDotComResult().getRecords();
        new MetadataService.ReadWorkflowTaskResult().getRecords();
        new MetadataService.ReadWorkflowSendResult().getRecords();
        new MetadataService.ReadWorkflowOutboundMessageResult().getRecords();
        new MetadataService.ReadWorkflowKnowledgePublishResult().getRecords();
        new MetadataService.ReadWorkflowFieldUpdateResult().getRecords();
        new MetadataService.ReadWorkflowAlertResult().getRecords();
        new MetadataService.ReadVisualizationPluginResult().getRecords();
        new MetadataService.ReadCustomMetadataResult().getRecords();
        new MetadataService.ReadNameSettingsResult().getRecords();
        new MetadataService.ReadMarketingActionSettingsResult().getRecords();
        new MetadataService.ReadCustomPermissionResult().getRecords();
        new MetadataService.ReadAuraDefinitionBundleResult().getRecords();
        new MetadataService.ReadCorsWhitelistOriginResult().getRecords();
        new MetadataService.ReadManagedTopicsResult().getRecords();
        new MetadataService.ReadTerritory2Result().getRecords();
        new MetadataService.ReadTerritory2ModelResult().getRecords();
        new MetadataService.ReadTerritory2SettingsResult().getRecords();
        new MetadataService.ReadTerritory2TypeResult().getRecords();
        new MetadataService.ReadXOrgHubResult().getRecords();
        new MetadataService.ReadActionLinkGroupTemplateResult().getRecords();
        new MetadataService.ReadLicenseDefinitionResult().getRecords();
        new MetadataService.ReadMarketingResourceTypeResult().getRecords();
        new MetadataService.ReadMatchingRuleResult().getRecords();
        new MetadataService.ReadMatchingRulesResult().getRecords();
        new MetadataService.ReadNamedCredentialResult().getRecords();
        new MetadataService.ReadPersonalJourneySettingsResult().getRecords();
        new MetadataService.ReadSharingRulesResult().getRecords();
        new MetadataService.ReadSharingBaseRuleResult().getRecords();
        new MetadataService.ReadSharingCriteriaRuleResult().getRecords();
        new MetadataService.ReadSharingOwnerRuleResult().getRecords();
        new MetadataService.ReadSharingTerritoryRuleResult().getRecords();
        new MetadataService.ReadMetadataWithContentResult().getRecords();
        new MetadataService.ReadCustomSiteResult().getRecords();
        new MetadataService.ReadListViewResult().getRecords();
        new MetadataService.ReadInstalledPackageResult().getRecords();
        new MetadataService.ReadCustomFieldResult().getRecords();
        new MetadataService.ReadFieldSetResult().getRecords();
        new MetadataService.ReadPicklistValueResult().getRecords();
        new MetadataService.ReadRecordTypeResult().getRecords();
        new MetadataService.ReadWebLinkResult().getRecords();
        new MetadataService.ReadAddressSettingsResult().getRecords();
        new MetadataService.ReadCaseSettingsResult().getRecords();
        new MetadataService.ReadCustomObjectResult().getRecords();
        new MetadataService.ReadLayoutResult().getRecords();
        new MetadataService.ReadEmailTemplateResult().getRecords();
        new MetadataService.ReadScontrolResult().getRecords();
        new MetadataService.ReadApexPageResult().getRecords();
        new MetadataService.ReadApexComponentResult().getRecords();
        new MetadataService.ReadApexClassResult().getRecords();
        new MetadataService.ReadApexTriggerResult().getRecords();
        new MetadataService.ReadStaticResourceResult().getRecords();
        new MetadataService.ReadDocumentResult().getRecords();
        new MetadataService.ReadCustomLabelsResult().getRecords();
        new MetadataService.ReadCustomLabelResult().getRecords();
        new MetadataService.ReadAccountSettingsResult().getRecords();
        new MetadataService.ReadQueueResult().getRecords();
        new MetadataService.ReadCustomDataTypeResult().getRecords();
        new MetadataService.ReadExternalDataSourceResult().getRecords();
        new MetadataService.ReadGroupResult().getRecords();
        new MetadataService.ReadBusinessProcessResult().getRecords();
        new MetadataService.ReadCompactLayoutResult().getRecords();
        new MetadataService.ReadSharingReasonResult().getRecords();
        new MetadataService.ReadValidationRuleResult().getRecords();
        new MetadataService.ReadReportTypeResult().getRecords();
        new MetadataService.ReadReportResult().getRecords();
        new MetadataService.ReadDashboardResult().getRecords();
        new MetadataService.ReadAnalyticSnapshotResult().getRecords();
        new MetadataService.ReadCustomPageWebLinkResult().getRecords();
        new MetadataService.ReadQuickActionResult().getRecords();
        new MetadataService.ReadFlexiPageResult().getRecords();
        new MetadataService.ReadCustomTabResult().getRecords();
        new MetadataService.ReadCustomApplicationComponentResult().getRecords();
        new MetadataService.ReadCustomApplicationResult().getRecords();
        new MetadataService.ReadPortalResult().getRecords();
        new MetadataService.ReadLetterheadResult().getRecords();
        new MetadataService.ReadFlowResult().getRecords();
        new MetadataService.ReadFlowResult().getRecords();
        new MetadataService.ReadDelegateGroupResult().getRecords();
        new MetadataService.ReadEventDeliveryResult().getRecords();
        new MetadataService.ReadEventSubscriptionResult().getRecords();
        new MetadataService.ReadEventTypeResult().getRecords();
        new MetadataService.ReadCertificateResult().getRecords();
        new MetadataService.ReadModerationRuleResult().getRecords();
        new MetadataService.ReadWaveApplicationResult().getRecords();
        new MetadataService.ReadWaveDatasetResult().getRecords();
        new MetadataService.ReadChannelLayoutResult().getRecords();
        new MetadataService.ReadContentAssetResult().getRecords();
        new MetadataService.ReadApexTestSuiteResult().getRecords();
        new MetadataService.ReadCustomValueResult().getRecords();
        new MetadataService.ReadStandardValueResult().getRecords();
        new MetadataService.ReadStandardValueSetResult().getRecords();
        new MetadataService.ReadGlobalPicklistValueResult().getRecords();
        new MetadataService.ReadGlobalValueSetResult().getRecords();
        new MetadataService.ReadSearchSettingsResult().getRecords();
        new MetadataService.ReadOrgPreferenceSettingsResult().getRecords();
        new MetadataService.ReadWaveLensResult().getRecords();
        new MetadataService.ReadWaveDataflowResult().getRecords();
        new MetadataService.ReadWaveDashboardResult().getRecords();
        new MetadataService.ReadEmailServicesFunctionResult().getRecords();
        new MetadataService.ReadEmbeddedServiceBrandingResult().getRecords();
        new MetadataService.ReadEmbeddedServiceConfigResult().getRecords();
        new MetadataService.ReadEmbeddedServiceLiveAgentResult().getRecords();
        new MetadataService.ReadCaseSubjectParticleResult().getRecords();
        new MetadataService.ReadNetworkBrandingResult().getRecords();
        new MetadataService.ReadSocialCustomerServiceSettingsResult().getRecords();
        new MetadataService.ReadTopicsForObjectsResult().getRecords();
        new MetadataService.ReadBrandingSetResult().getRecords();
        new MetadataService.ReadProfilePasswordPolicyResult().getRecords();
        new MetadataService.ReadProfileSessionSettingResult().getRecords();
        new MetadataService.ReadCspTrustedSiteResult().getRecords();
        new MetadataService.ReadEclairGeoDataResult().getRecords();
        new MetadataService.ReadExternalServiceRegistrationResult().getRecords();
        new MetadataService.ReadFileUploadAndDownloadSecuritySettingsResult().getRecords();
        new MetadataService.ReadLeadConvertSettingsResult().getRecords();
        new MetadataService.ReadUserCriteriaResult().getRecords();
        new MetadataService.ReadWavexmdResult().getRecords();
        Test.stopTest();
    }

    @IsTest
    private static void elfMissingGetResultTest() { // elf patch
        Test.startTest();
        new MetadataService.readWorkflowRuleResponse_element().getResult();
        new MetadataService.readSamlSsoConfigResponse_element().getResult();
        new MetadataService.readCustomLabelResponse_element().getResult();
        new MetadataService.readBusinessHoursEntryResponse_element().getResult();
        new MetadataService.readMobileSettingsResponse_element().getResult();
        new MetadataService.readChatterAnswersSettingsResponse_element().getResult();
        new MetadataService.readSharingRulesResponse_element().getResult();
        new MetadataService.readPortalResponse_element().getResult();
        new MetadataService.readSkillResponse_element().getResult();
        new MetadataService.readEscalationRulesResponse_element().getResult();
        new MetadataService.readCustomDataTypeResponse_element().getResult();
        new MetadataService.readExternalDataSourceResponse_element().getResult();
        new MetadataService.readEntitlementProcessResponse_element().getResult();
        new MetadataService.readRecordTypeResponse_element().getResult();
        new MetadataService.readScontrolResponse_element().getResult();
        new MetadataService.readDataCategoryGroupResponse_element().getResult();
        new MetadataService.readValidationRuleResponse_element().getResult();
        new MetadataService.readProfileResponse_element().getResult();
        new MetadataService.readIdeasSettingsResponse_element().getResult();
        new MetadataService.readConnectedAppResponse_element().getResult();
        new MetadataService.readApexPageResponse_element().getResult();
        new MetadataService.readProductSettingsResponse_element().getResult();
        new MetadataService.readLiveAgentSettingsResponse_element().getResult();
        new MetadataService.readOpportunitySettingsResponse_element().getResult();
        new MetadataService.readLiveChatDeploymentResponse_element().getResult();
        new MetadataService.readActivitiesSettingsResponse_element().getResult();
        new MetadataService.readLayoutResponse_element().getResult();
        new MetadataService.readWebLinkResponse_element().getResult();
        new MetadataService.readSiteDotComResponse_element().getResult();
        new MetadataService.readCompanySettingsResponse_element().getResult();
        new MetadataService.readHomePageLayoutResponse_element().getResult();
        new MetadataService.readDashboardResponse_element().getResult();
        new MetadataService.readAssignmentRulesResponse_element().getResult();
        new MetadataService.readAnalyticSnapshotResponse_element().getResult();
        new MetadataService.readEscalationRuleResponse_element().getResult();
        new MetadataService.readCustomSiteResponse_element().getResult();
        new MetadataService.readGroupResponse_element().getResult();
        new MetadataService.readReportTypeResponse_element().getResult();
        new MetadataService.readQuickActionResponse_element().getResult();
        new MetadataService.readCustomPageWebLinkResponse_element().getResult();
        new MetadataService.readApexComponentResponse_element().getResult();
        new MetadataService.readEntitlementTemplateResponse_element().getResult();
        new MetadataService.readFlexiPageResponse_element().getResult();
        new MetadataService.readWorkflowResponse_element().getResult();
        new MetadataService.readWorkflowActionResponse_element().getResult();
        new MetadataService.readAddressSettingsResponse_element().getResult();
        new MetadataService.readContractSettingsResponse_element().getResult();
        new MetadataService.readCustomObjectResponse_element().getResult();
        new MetadataService.readTranslationsResponse_element().getResult();
        new MetadataService.readRoleOrTerritoryResponse_element().getResult();
        new MetadataService.readApexTriggerResponse_element().getResult();
        new MetadataService.readCustomLabelsResponse_element().getResult();
        new MetadataService.readSecuritySettingsResponse_element().getResult();
        new MetadataService.readCallCenterResponse_element().getResult();
        new MetadataService.readPicklistValueResponse_element().getResult();
        new MetadataService.readRemoteSiteSettingResponse_element().getResult();
        new MetadataService.readQuoteSettingsResponse_element().getResult();
        new MetadataService.readSynonymDictionaryResponse_element().getResult();
        new MetadataService.readPostTemplateResponse_element().getResult();
        new MetadataService.readCustomTabResponse_element().getResult();
        new MetadataService.readLetterheadResponse_element().getResult();
        new MetadataService.readInstalledPackageResponse_element().getResult();
        new MetadataService.readQueueResponse_element().getResult();
        new MetadataService.readAuthProviderResponse_element().getResult();
        new MetadataService.readEntitlementSettingsResponse_element().getResult();
        new MetadataService.readCustomFieldResponse_element().getResult();
        new MetadataService.readStaticResourceResponse_element().getResult();
        new MetadataService.readEmailTemplateResponse_element().getResult();
        new MetadataService.readSharingReasonResponse_element().getResult();
        new MetadataService.readLiveChatButtonResponse_element().getResult();
        new MetadataService.readNetworkResponse_element().getResult();
        new MetadataService.readApprovalProcessResponse_element().getResult();
        new MetadataService.readMilestoneTypeResponse_element().getResult();
        new MetadataService.readAssignmentRuleResponse_element().getResult();
        new MetadataService.readCompactLayoutResponse_element().getResult();
        new MetadataService.readLiveChatAgentConfigResponse_element().getResult();
        new MetadataService.readAccountSettingsResponse_element().getResult();
        new MetadataService.readBusinessProcessResponse_element().getResult();
        new MetadataService.readFlowResponse_element().getResult();
        new MetadataService.readAutoResponseRuleResponse_element().getResult();
        new MetadataService.readPermissionSetResponse_element().getResult();
        new MetadataService.readBusinessHoursSettingsResponse_element().getResult();
        new MetadataService.readForecastingSettingsResponse_element().getResult();
        new MetadataService.readReportResponse_element().getResult();
        new MetadataService.readAppMenuResponse_element().getResult();
        new MetadataService.readListViewResponse_element().getResult();
        new MetadataService.readOrderSettingsResponse_element().getResult();
        new MetadataService.readCustomObjectTranslationResponse_element().getResult();
        new MetadataService.readCustomApplicationResponse_element().getResult();
        new MetadataService.readKnowledgeSettingsResponse_element().getResult();
        new MetadataService.readCaseSettingsResponse_element().getResult();
        new MetadataService.readApexClassResponse_element().getResult();
        new MetadataService.readPackageResponse_element().getResult();
        new MetadataService.readCommunityResponse_element().getResult();
        new MetadataService.readDocumentResponse_element().getResult();
        new MetadataService.readAutoResponseRulesResponse_element().getResult();
        new MetadataService.readFolderResponse_element().getResult();
        new MetadataService.readCustomApplicationComponentResponse_element().getResult();
        new MetadataService.readFieldSetResponse_element().getResult();
        new MetadataService.readSharingSetResponse_element().getResult();
        new MetadataService.readHomePageComponentResponse_element().getResult();
        new MetadataService.readReportFolderResponse_element().getResult();
        new MetadataService.readDashboardFolderResponse_element().getResult();
        new MetadataService.readFlowResponse_element().getResult();
        new MetadataService.readFlowResponse_element().getResult();
        new MetadataService.readDocumentFolderResponse_element().getResult();
        new MetadataService.readEmailFolderResponse_element().getResult();
        new MetadataService.readWorkflowTaskResponse_element().getResult();
        new MetadataService.readWorkflowSendResponse_element().getResult();
        new MetadataService.readWorkflowOutboundMessageResponse_element().getResult();
        new MetadataService.readWorkflowKnowledgePublishResponse_element().getResult();
        new MetadataService.readWorkflowFieldUpdateResponse_element().getResult();
        new MetadataService.readWorkflowAlertResponse_element().getResult();
        new MetadataService.readVisualizationPluginResponse_element().getResult();
        new MetadataService.readCustomMetadataResponse_element().getResult();
        new MetadataService.readNameSettingsResponse_element().getResult();
        new MetadataService.readMarketingActionSettingsResponse_element().getResult();
        new MetadataService.readCustomPermissionResponse_element().getResult();
        new MetadataService.readAuraDefinitionBundleResponse_element().getResult();
        new MetadataService.readCorsWhitelistOriginResponse_element().getResult();
        new MetadataService.readManagedTopicsResponse_element().getResult();
        new MetadataService.readTerritory2Response_element().getResult();
        new MetadataService.readTerritory2ModelResponse_element().getResult();
        new MetadataService.readTerritory2SettingsResponse_element().getResult();
        new MetadataService.readTerritory2TypeResponse_element().getResult();
        new MetadataService.readXOrgHubResponse_element().getResult();
        new MetadataService.readActionLinkGroupTemplateResponse_element().getResult();
        new MetadataService.readLicenseDefinitionResponse_element().getResult();
        new MetadataService.readMarketingResourceTypeResponse_element().getResult();
        new MetadataService.readMatchingRuleResponse_element().getResult();
        new MetadataService.readMatchingRulesResponse_element().getResult();
        new MetadataService.readNamedCredentialResponse_element().getResult();
        new MetadataService.readPersonalJourneySettingsResponse_element().getResult();
        new MetadataService.readSharingBaseRuleResponse_element().getResult();
        new MetadataService.readSharingCriteriaRuleResponse_element().getResult();
        new MetadataService.readSharingOwnerRuleResponse_element().getResult();
        new MetadataService.readSharingTerritoryRuleResponse_element().getResult();
        new MetadataService.readMetadataWithContentResponse_element().getResult();
        new MetadataService.readDelegateGroupResponse_element().getResult();
        new MetadataService.readEventDeliveryResponse_element().getResult();
        new MetadataService.readEventSubscriptionResponse_element().getResult();
        new MetadataService.readEventTypeResponse_element().getResult();
        new MetadataService.readCertificateResponse_element().getResult();
        new MetadataService.readModerationRuleResponse_element().getResult();
        new MetadataService.readWaveApplicationResponse_element().getResult();
        new MetadataService.readWaveDatasetResponse_element().getResult();
        new MetaDataService.readWaveDataflowResponse_element().getResult();
        new MetaDataService.readWaveLensResponse_element().getResult();
        new MetaDataService.readOrgPreferenceSettingsResponse_element().getResult();
        new MetaDataService.readSearchSettingsResponse_element().getResult();
        new MetadataService.readGlobalPicklistValueResponse_element().getResult();
        new MetadataService.readPicklistValueResponse_element().getResult();
        new MetadataService.readContentAssetResponse_element().getResult();
        new MetadataService.readChannelLayoutResponse_element().getResult();
        new MetadataService.readApexTestSuiteResponse_element().getResult();
        new MetadataService.readCustomValueResponse_element().getResult();
        new MetadataService.readStandardValueResponse_element().getResult();
        new MetadataService.readStandardValueSetResponse_element().getResult();
        new MetadataService.readGlobalValueSetResponse_element().getResult();
        new MetadataService.readWaveDashboardResponse_element().getResult();
        new MetadataService.readEmailServicesFunctionResponse_element().getResult();
        new MetadataService.readEmbeddedServiceBrandingResponse_element().getResult();
        new MetadataService.readEmbeddedServiceConfigResponse_element().getResult();
        new MetadataService.readEmbeddedServiceLiveAgentResponse_element().getResult();
        new MetadataService.readCaseSubjectParticleResponse_element().getResult();
        new MetadataService.readNetworkBrandingResponse_element().getResult();
        new MetadataService.readSocialCustomerServiceSettingsResponse_element().getResult();
        new MetadataService.readTopicsForObjectsResponse_element().getResult();
        new MetadataService.readBrandingSetResponse_element().getResult();
        new MetadataService.readProfilePasswordPolicyResponse_element().getResult();
        new MetadataService.readProfileSessionSettingResponse_element().getResult();
        new MetadataService.readCspTrustedSiteResponse_element().getResult();
        new MetadataService.readEclairGeoDataResponse_element().getResult();
        new MetadataService.readExternalServiceRegistrationResponse_element().getResult();
        new MetadataService.readFileUploadAndDownloadSecuritySettingsResponse_element().getResult();
        new MetadataService.readLeadConvertSettingsResponse_element().getResult();
        new MetadataService.readUserCriteriaResponse_element().getResult();
        new MetadataService.readWavexmdResponse_element().getResult();
        Test.stopTest();
    }

     */
}