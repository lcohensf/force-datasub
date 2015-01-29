/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@isTest
private class TestHerokuApi {

    static testMethod void testSubscribe() {  
    	upsert new Integration__c(Name = 'JWTToken',Key__c = 'test');
    	upsert new Integration__c(Name = 'DataServiceURL',Key__c = 'https:/test.com');
    	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new HerokuRequestMock());
    	
    	List<Physician__c> physicians = new List<Physician__c>();
    	Physician__c p1 = new Physician__c();
    	p1.Physician_ID__c = 'p1';
    	Physician__c p2 = new Physician__c();
    	p2.Physician_ID__c = 'p2';
    	physicians.add(p1);
    	physicians.add(p2);
    	
    	HttpResponse res = HerokuApi.subscribeWithHeroku(physicians);
    	System.assertEquals(200, res.getStatusCode());
    	Test.stopTest();

    }
    static testMethod void testFindPhysicians() { 
    	upsert new Integration__c(Name = 'JWTToken',Key__c = 'test');
    	upsert new Integration__c(Name = 'DataServiceURL',Key__c = 'https:/test.com');
    	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new HerokuFindPhysiciansRequestMock());	
 
    	List<HerokuApi.PhysicianObject> returnedPhysicians = HerokuApi.findPhysiciansOnHeroku('p', '', '');
    	System.assertEquals(2, returnedPhysicians.size());
    	Test.stopTest();
    }
    static testMethod void testPhysicianObject() {
    	HerokuApi.PhysicianObject po = new HerokuApi.PhysicianObject('ln', 'fn', 'sp', 'zc', 'pid');
    	System.assertEquals('ln', po.last_name);
    	System.assertEquals('fn', po.first_name);
    	System.assertEquals('sp', po.specialization);
    	System.assertEquals('zc', po.zipcode);
    	System.assertEquals('pid', po.physician_id);
		po.last_name = 'ln2';
		po.first_name = 'fn2';
		po.specialization = 'sp2';
		po.zipcode = 'zc2';
		po.physician_id = 'pid2';
		System.assertEquals('ln2', po.last_name);
    	System.assertEquals('fn2', po.first_name);
    	System.assertEquals('sp2', po.specialization);
    	System.assertEquals('zc2', po.zipcode);
    	System.assertEquals('pid2', po.physician_id);
	
    }
}