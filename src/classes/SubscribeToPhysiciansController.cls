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

public with sharing class SubscribeToPhysiciansController {

 
/*
* item in context from the page
*/
public String contextItem{get;set;}
 
 
/*
* custom attributes for custom set controller
*/
private Integer pageNumber;
private Integer pageSize; 
private Integer currentPageNumber;
private List<HerokuApi.PhysicianObject> externalPhysiciansList;
private Set<String> currentlySubscribedPhysiciansIDs;

/*
* the physician external ids selected by the user
*/
private Set<String> selectedPhysicianIds;
    
/*
* constructor
*/
public SubscribeToPhysiciansController ()
{
    //init variable
    this.selectedPhysicianIds= new Set<String>();
    
    //gather data set
    this.externalPhysiciansList = findPhysicians();
    this.currentlySubscribedPhysiciansIDs = getCurrentlySubscribedPhysiciansIds();
    this.pageNumber = 1;
    this.pageSize = 10;
    this.currentPageNumber = 1;

}

/*
* handle item selected
*/
public void doSelectItem(){
    this.selectedPhysicianIds.add(this.contextItem);
    System.debug('*********** Selected: ' + this.contextItem);
}
/*
* handle item deselected
*/
public void doDeselectItem(){
    this.selectedPhysicianIds.remove(this.contextItem);
}

/*
* return count of selected items
*/
public Integer getSelectedCount(){
    return this.selectedPhysicianIds.size();
}
/*
* advance to next page
*/
public void doNext(){
    if (this.getHasNext())
        currentPageNumber = currentPageNumber + 1;
 
}
/*
* advance to previous page
*/
public void doPrevious(){
    if (this.getHasPrevious()) {
        currentPageNumber = currentPageNumber - 1;
    }
}
    /*
* return whether previous page exists
*/
public Boolean getHasPrevious(){
    if (this.currentPageNumber == 1) return false;
    return true;
}
/*
* return whether next page exists
*/
public Boolean getHasNext(){
    if (this.currentPageNumber == this.getTotalPages()) return false;
    return true;
}
/*
* return page number
*/
public Integer getPageNumber(){
    return this.currentPageNumber;
}
/*
* return total pages
*/
Public Integer getTotalPages(){
    Decimal totalSize = externalPhysiciansList.size();
    Decimal pageSize = this.pageSize;
    Decimal pages = totalSize/pageSize;
    return (Integer)pages.round(System.RoundingMode.CEILING);
}
/*
* return current page of groups
*/
public List<PhysRowItem> getPhysicians(){
    List<PhysRowItem> rows = new List<PhysRowItem>();
    Integer startIndex, endIndex;
    
    startIndex = (this.currentPageNumber - 1) * this.pageSize;
    endIndex = startIndex + this.pageSize - 1;
    
    if (endIndex > (externalPhysiciansList.size() - 1)) {
        endIndex = externalPhysiciansList.size() - 1;
    }
    
    for(Integer i = startIndex; i <= endIndex; i++) {
        HerokuApi.PhysicianObject p = externalPhysiciansList.get(i);
        PhysRowItem row = new PhysRowItem(p,false,false);
        if (currentlySubscribedPhysiciansIds.contains(p.physician_id)) {
        	row.IsSelected=true;
        	row.IsDisabled=true;
        } else if (this.selectedPhysicianIds.contains(p.physician_id)){
            row.IsSelected=true;
        }

        rows.add(row);
    }
    return rows;
}

private Set<String> getCurrentlySubscribedPhysiciansIds() {
	Set<String> externalPhysiciansIds = new Set<String>();
	for(HerokuApi.PhysicianObject r : externalPhysiciansList){
		externalPhysiciansIds.add(r.physician_id);
	}
	Set<String> subscribedPhysicians = new Set<String>();
	
	if (externalPhysiciansIds.size() > 0) {
		List<Physician__c> phys  = [Select Physician_ID__c from Physician__c where Physician_ID__c in :externalPhysiciansIds limit 200];
		for (Physician__c p : phys) {
			subscribedPhysicians.add(p.Physician_ID__c);
		}
	}
	return subscribedPhysicians;
}
    
/*
* helper class that represents a row
*/
public with sharing class PhysRowItem{
    public HerokuApi.PhysicianObject tPhysician{get;set;}

    public Boolean IsSelected{get;set;}
    public Boolean IsDisabled{get;set;}
    public PhysRowItem(HerokuApi.PhysicianObject p, Boolean s, Boolean d){
        this.tPhysician=p;
        this.IsSelected=s;
        this.IsDisabled=d;
    }
}
    
private List<HerokuApi.PhysicianObject> findPhysicians() {
    String last_name = ApexPages.currentPage().getParameters().get('last_name');
    String specialization = ApexPages.currentPage().getParameters().get('specialization');
    String zipcode = ApexPages.currentPage().getParameters().get('zipcode');

	return HerokuApi.findPhysiciansOnHeroku(last_name, specialization, zipcode);
}
       
    
public PageReference doSubscribe(){
    
   List<Physician__c> rows = new List<Physician__c>();
   for(HerokuApi.PhysicianObject r : externalPhysiciansList){
        
        
        if (this.selectedPhysicianIds.contains(r.physician_id)){
            Physician__c newp = new Physician__c();
 
            newp.First_Name__c = r.first_name;
            newp.Last_Name__c = r.last_name;
            newp.Physician_ID__c = r.physician_id;
            newp.Specialization__c = r.specialization;
            newp.Zip_Postal_Code__c = r.zipcode;
            rows.add(newp);
        }
    }

    HerokuApi.SubscribeWithHeroku(rows);
    

    if (!rows.isEmpty()) {
    	try {
    		upsert rows Physician_ID__c;
    	} catch (DMLException e) {
    		System.debug('**************************** Error upserting Physicians in SubscribeToPhysiciansController.doSubscribe: ' + e.getMessage());
    		return null;
    	}
    }
    if (!rows.isEmpty()) {
	    Schema.DescribeSObjectResult result = Physician__c.SObjectType.getDescribe();
	
	    PageReference pageRef = new PageReference('/' + result.getKeyPrefix());
	    pageRef.setRedirect(true);
	    return pageRef;

    } else {
    	return null;
    }

}

}