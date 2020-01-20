import { LightningElement, track,wire } from 'lwc';
import getMyContractList  from '@salesforce/apex/cep_mycontractView.getMyContractList';
export default class Cep_mycontractView extends LightningElement {
    
    @track contracts;
    @wire(getMyContractList) myContracts;
   connectedCallback(){
        let rec = [ {
            'Id': '1',
            'contractType': 'dummyContract',
            'startDate': '2019-01-10',
            'endDate': '2019-01-10',
            'holderAccount': 'Testing Account',
            'asset': 'Test Contact'
            
          },
          {
            'Id': '2',
            'contractType': 'dummyContract',
            'startDate': '2019-01-10',
            'endDate': '2019-01-10',
            'holderAccount': 'Testing Account',
            'asset': 'Test Contact'
          },
          {
            'Id': '3',
            'contractType': 'dummyContract',
            'startDate': '2019-01-10',
            'endDate': '2019-01-10',
            'holderAccount': 'Testing Account',
            'asset': 'Test Contact'
          }
    
        ];
this.contracts = rec;

}
}