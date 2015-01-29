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
private class TestSubscribeToPhysiciansController {

    static testMethod void myUnitTest() {
       
        
        upsert new Integration__c(Name = 'JWTToken',Key__c = 'test');
        upsert new Integration__c(Name = 'DataServiceURL',Key__c = 'https:/test.com');
        
    	Physician__c p1 = new Physician__c();
    	p1.Physician_ID__c = 'p1pid';
    	p1.First_Name__c = 'p1fn';
    	p1.Last_Name__c = 'p1ln';
    	p1.Specialization__c = 'p1s';
    	p1.Zip_Postal_Code__c = 'p1z';

    	// this test assumes user is already subscribed to one of the physicians
    	insert p1;
    	
    	Test.startTest();
    	
    	Test.setMock(HttpCalloutMock.class, new HerokuFindPhysiciansRequestMock());
    	Test.setCurrentPage(Page.SubscribeToPhysicians);
    	ApexPages.currentPage().getParameters().put('query', 'p');
    	 
    	SubscribeToPhysiciansController ctrl = new SubscribeToPhysiciansController();
    	
    	Integer val = ctrl.getSelectedCount();
    	System.assertEquals(0, val);
    	val = ctrl.getPageNumber();
    	System.assertEquals(1, val);
    	val = ctrl.getTotalPages();
    	System.assertEquals(1, val);
    	Boolean bval = ctrl.getHasNext();
    	System.assertEquals(false, bval);
		bval = ctrl.getHasPrevious();
    	System.assertEquals(false, bval);
    	ctrl.doNext();
    	System.assertEquals(1, ctrl.getPageNumber()); // only one page, so this shouldn't change page num
    	ctrl.doPrevious();
		System.assertEquals(1, ctrl.getPageNumber());
		
		List<SubscribeToPhysiciansController.PhysRowItem> physiciansInPage = ctrl.getPhysicians();
		System.assertEquals(2, physiciansInPage.size());
		System.debug('******* phys0: ' + physiciansInPage[0].tPhysician.last_name);
		System.debug('******* phys1: ' + physiciansInPage[1].tPhysician.last_name);
		System.assertEquals(true, physiciansInPage[0].isDisabled);
		System.assertEquals(true, physiciansInPage[0].isSelected);
		System.assertEquals(false, physiciansInPage[1].isDisabled);
		System.assertEquals(false, physiciansInPage[1].isSelected);
		
		ctrl.contextItem = 'p2pid';
		ctrl.doSelectItem();
		System.assertEquals(1, ctrl.getSelectedCount());
		ctrl.doDeselectItem();
		System.assertEquals(0, ctrl.getSelectedCount());
		ctrl.doSelectItem(); //leave 2nd subscribed for subscribe test
		System.assertEquals(1, ctrl.getSelectedCount());
		
		Test.setMock(HttpCalloutMock.class, new HerokuRequestMock());
		PageReference returnedPage = ctrl.doSubscribe();
		
		Schema.DescribeSObjectResult result = Physician__c.SObjectType.getDescribe();	
	    PageReference expectedPage = new PageReference('/' + result.getKeyPrefix());
		System.assertEquals(expectedPage.getURL(), returnedPage.getURL());
		
		List<Physician__c> saved = [select Physician_ID__c from Physician__c where Physician_ID__c = 'p2pid'];
		System.assertEquals('p2pid', saved[0].Physician_ID__c);
		
    	Test.stopTest();
    }
}