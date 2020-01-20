import { LightningElement, track  } from 'lwc';

export default class CEP_TicketFilter extends LightningElement {

    @track typeOptions =[ {
        'label': 'Portal Support',
        'value': 'Portal Support'
      },
      {
        'label': 'Unit Related',
        'value': 'Unit Related'
      },
      {
        'label': 'myOutages',
        'value': 'myOutages'
      }
    ];
    @track statusOptions =  [ {
        'label': 'In Progress',
        'value': 'In Progress'
      },
      {
        'label': 'Completed',
        'value': 'Completed'
      },
      {
        'label': 'Recommendation Provided',
        'value': 'Recommendation Provided'
      } ];

      handleChange(event) {
       // const selectedOption = event.detail.value;
        //alert("hello there!"); 
        //this.template.querySelector('input[name="search"]').value="mySearch";
        
      }
}