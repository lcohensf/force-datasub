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

public class HerokuApi {
 public static HttpResponse SubscribeWithHeroku(List<Physician__c> rows) {
        Integration__c aValue = Integration__c.getValues('JWTToken'); //get the values stored protected custom setting
        string jwt_token = aValue.Key__c;
        aValue = Integration__c.getValues('DataServiceURL');
        String serviceEndpoint = aValue.Key__c;
        
        String orgId = UserInfo.getOrganizationId();
        String jsonBody = '{"jwt_token" : "' + jwt_token + '", "sf_org_id" : "' + orgId + '", "physician_ids" : [';
        Boolean isfirst = true;
        for (Physician__c p : rows) {
            if (!isFirst) {
                jsonBody = jsonBody + ', ';
            }
            isFirst = false;
            jsonBody = jsonBody + '"' + p.Physician_ID__c + '"';
    	}
        jsonBody = jsonBody + ']}';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint( serviceEndpoint + '/subscribe');
        req.setHeader('Accept-Encoding','gzip');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        
        req.setCompressed(false);
        req.setBody(jsonBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    

	public with sharing class PhysicianObject {     // inner class for serialization
        public String last_name{get;set;}
        public String first_name{get;set;}
        public String specialization{get;set;}
        public String zipcode{get;set;}
        public String physician_id{get;set;}
        public PhysicianObject(String ln, String fn, String sp, String z, String pid) {
            last_name = ln;
            first_name = fn;
            specialization = sp;
            zipcode = z;
            physician_id = pid;
        }
	}
	
	public static List<PhysicianObject> findPhysiciansOnHeroku(String last_name, String specialization, String zipcode) {
    	List<PhysicianObject> physList = new List<PhysicianObject>();
     
        Integration__c aValue = Integration__c.getValues('JWTToken');
        string jwt_token = aValue.Key__c;
        aValue = Integration__c.getValues('DataServiceURL');
        String serviceEndpoint = aValue.Key__c;
        
        String orgId = UserInfo.getOrganizationId();
        String jsonBody = '{"jwt_token" : "' + jwt_token + '", "sf_org_id" : "' + orgId 
        + '", "last_name" : "' + last_name + '", "specialization" : "' + specialization
        + '", "zipcode" : "' + zipcode
        + '"}';
      
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint( serviceEndpoint + '/findPhysicians');
        req.setHeader('Accept-Encoding','gzip');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        
        req.setCompressed(false);
        req.setBody(jsonBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);

    	if (res.getStatusCode()==200) {  
    		String physiciansJSON = res.getBody();
    		JSONParser parser = JSON.createParser(physiciansJSON);
    		while (parser.nextToken() != null) {
        		if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            		while (parser.nextToken() != null) {
                		if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                   	 		PhysicianObject p = (PhysicianObject)parser.readValueAs(PhysicianObject.class);
                    		physList.add(p);
                		}
            		}
        		}
    		}
    	
    	}
		return physList;
	}
	
}