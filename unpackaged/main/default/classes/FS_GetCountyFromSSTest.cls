@IsTest
global class FS_GetCountyFromSSTest {
    
    @TestSetup
    static void initData() {
        Account account = new Account(
            Name = 'Fusion Span'
        );
        insert account;
        Contact contact = new Contact(
            LastName = 'Gilmour'
        );
        insert contact;
    }

    @IsTest
    static void testKnownAddress() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c(
            OrderApi__Country__c = 'United States', 
            OrderApi__Street__c = '320 N Soto St', 
            OrderApi__City__c = 'Los Angeles', 
            OrderApi__Province__c = 'CA'
        );
        insert knownAddress;
            
        Test.startTest();
        FS_GetCountyFromSS calloutJob = new FS_GetCountyFromSS(knownAddress);
		Id jobId = System.enqueueJob(calloutJob);
        Test.stopTest();
    }        
    
	global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HttpResponse respond(HttpRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                    '{'+
                        '"input_id": "0",'+
                        '"input_index": 0,'+
                        '"candidate_index": 0,'+
                        '"delivery_line_1": "12300 Twinbrook Pkwy Ste 440",'+
                        '"last_line": "Rockville MD 20852-1650",'+
                        '"delivery_point_barcode": "208521650155",'+
                        '"components": {'+
                            '"primary_number": "12300",'+
                            '"street_name": "Twinbrook",'+
                            '"street_suffix": "Pkwy",'+
                            '"secondary_number": "440",'+
                            '"secondary_designator": "Ste",'+
                            '"city_name": "Rockville",'+
                            '"default_city_name": "Rockville",'+
                            '"state_abbreviation": "MD",'+
                            '"zipcode": "20852",'+
                            '"plus4_code": "1650",'+
                            '"delivery_point": "15",'+
                            '"delivery_point_check_digit": "5"'+
                        '},'+
                        '"metadata": {'+
                            '"record_type": "H",'+
                            '"zip_type": "Standard",'+
                            '"county_fips": "24031",'+
                            '"county_name": "Montgomery",'+
                            '"carrier_route": "C083",'+
                            '"congressional_district": "08",'+
                            '"rdi": "Commercial",'+
                            '"elot_sequence": "0024",'+
                            '"elot_sort": "A",'+
                            '"latitude": 39.0589,'+
                            '"longitude": -77.12134,'+
                            '"precision": "Zip9",'+
                            '"time_zone": "Eastern",'+
                            '"utc_offset": -5,'+
                            '"dst": true'+
                        '},'+
                        '"analysis": {'+
                            '"dpv_match_code": "Y",'+
                            '"dpv_footnotes": "AABB",'+
                            '"dpv_cmra": "N",'+
                            '"dpv_vacant": "N",'+
                            '"active": "Y",'+
                            '"footnotes": "N#"'+
                        '}'+
                    '}');
            res.setStatusCode(200);
            return res;
        }
    }
}