import { LightningElement, track  } from 'lwc';

export default class CEP_TicketFilter extends LightningElement {
@track items;
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

   handleClick(){

      if(typeof this.testVar == 'undefined'){
          this.testVar = [];
      }
      this.testVar =  this.testVar.map(element => {
          return {
             'label':element.label,
             'name':element.name
            };
      });

      this.testVar.push({
          'label':'Test3',
          'name': 'Test3'
        });

    }


   handleChange(event){
   
   // Get the string of the "value" attribute on the selected option
        const selectedOption = event.detail.value;
        const selectlabel =event.target.label;
        let filters={};
        let tempCheck=[];
            
        /*const changeElement=[];
            changeElement.push({
            'label': selectlabel,
            'name': selectedOption
            });*/
		   tempCheck.push({
              'label': selectlabel,
              'name': selectedOption
            });
			
			if( typeof this.items === "undefined"){
                this.items=[];
            }else{
                let local=this.items
					.filter(element =>element.label !== selectlabel)
					.map(element => {
							return {
								'label':element.label,
								'name':element.name
							};
						});
                 local=local.concat(tempCheck)  ;     
				tempCheck=local;
			}
			this.items=tempCheck;
		  
		  /*filters=this.items.map(element => {
        return {
         'label':element.label,
         'name':element.name
        };
       });*/
       this.items.forEach(element => {

        filters[element.label] = element.name;
         
       });
		   const filterChangeEvent = new CustomEvent('filterchange', {detail: { filters }, });
		// Fire the custom event
         this.dispatchEvent(filterChangeEvent);
    }


  handleItemRemove (event) {

  this.items = this.items.map(element => {
        return {
           'label':element.label,
           'name':element.name
          };
      });
this.items.splice(event.detail.index,1);
const name = event.detail.item.name;
console.log(name + ' pill was removed!');
const index = event.detail.index;
const targetNode=Array.from(this.template.querySelectorAll('lightning-combobox'))
                    .filter(element =>element.value == name);
    targetNode[0].value=undefined;                  
     
    }
}