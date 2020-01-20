import { LightningElement, track } from 'lwc';

export default class Cep_ticketTracking extends LightningElement {
    @track displayDetails;
    @track selectedTicket;
    @track fullList;
    @track filteredList;
    @track showSpinner;

    connectedCallback(){
        let rec = [ {
            'Id': '1',
            'ticketNumber': '123',
            'AccountName': 'Testing Account',
            'contactName': 'Test Contact',
            'subject': 'The Content mentioned here is just for testing',
            'status': 'completed',
            'ticketType': 'Unit Related',
            'relatedUnit': 'Related Unit Details',
            'createdDate': '2019-01-10',
            'description': 'Test Description'
          },
          {
            'Id': '2',
            'ticketNumber': '456',
            'AccountName': 'Testing Account',
            'contactName': 'Test Contact',
            'subject': 'The Content mentioned here is just for testing',
            'status': 'In Progress',
            'ticketType': 'Unit Related',
            'relatedUnit': 'Unit',
            'createdDate': '2019-01-11',
            'description': 'Test Description'
          },
          {
            'Id': '3',
            'ticketNumber': '789',
            'AccountName': 'Testing Account',
            'contactName': 'Test Contact',
            'subject': 'The Content mentioned here is just for testing',
            'status': 'completed',
            'ticketType': 'Portal Support',
            'relatedUnit': 'Details',
            'createdDate': '2019-01-12',
            'description': 'Test Description'
          }
    
        ];

        this.filteredList = rec;
        this.fullList = rec;

    }

    filterData(event){

      let filterRec = event.detail.filters;

      let search = filterRec['Search']?filterRec['Search'].toLowerCase():'';

      this.filteredList = this.fullList.filter(rec =>{
        return filterRec['Type']?rec.ticketType === filterRec['Type']:true;
      }).filter(rec =>{
          return filterRec['Status']?rec.status.toLowerCase() === filterRec['Status'].toLowerCase():true;
      }).filter(rec =>{
          return search?(rec.ticketNumber.indexOf(search) !== -1 || (rec.relatedUnit).toLowerCase().indexOf(search) !== -1 ||
                           rec.createdDate.indexOf(search) !== -1):true;
      });

    }

    close(){
        this.displayDetails = false;
    }

    showDetails(event){
        this.selectedTicket = this.fullList.find( rec => {
            return rec.Id === event.currentTarget.dataset.id;
          });
        this.displayDetails=true;
    }


}