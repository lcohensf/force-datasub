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

public class SubWiz {
	public String last_name { get; set; }
	public String specialization { get; set; }
	public String zipcode { get; set; }
    public PageReference Transfer() {
    	if ((last_name == null || last_name.length() == 0) &&
    		(specialization == null || specialization.length() == 0) &&
    		(zipcode == null || zipcode.length() == 0)) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one filter condition is required.'));
    		return null;
    	}
        PageReference newPage = page.SubscribeToPhysicians;
        //newPage.getParameters().put('query', String.escapeSingleQuotes(query)); // incorrectly escapes for URL param
        //server app sanitizes query param
        newPage.getParameters().put('last_name', last_name);
        newPage.getParameters().put('specialization', specialization);
        newPage.getParameters().put('zipcode', zipcode);
        
        return newPage;
    }
}