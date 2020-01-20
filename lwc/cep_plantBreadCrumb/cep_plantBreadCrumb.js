import { LightningElement, track, wire } from 'lwc';
//import { CurrentPageReference } from 'lightning/navigation';
import  {fireEvent} from 'c/pubsub';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  getAssetDetails  from '@salesforce/apex/CEPAssetPlantToolsCont.getAssetDetails';
export default class Cep_plantBreadCrumb extends NavigationMixin(LightningElement) {

    plantsList;
    equipmentList;
    toolsList;
    toolsDetails;

    @track error;
    @track filteredEquipmentList = [];
    @track showHidePlantPopup;
    @track showHideEquipPopup;
    @track selectedPlant= 'Select Plant';
    @track selectedPlantId;
    @track selectedEquipment= 'Select Equipment';
    @track selectedEquipmentId;
    @track selectedTool = 'Select Tool';
    @track displayToolsList;
    @track showHideToolPopup;

  /*  @wire(CurrentPageReference)
    pageRef;*/


    @wire(getAssetDetails)
    assetInfo({data,error}){

        if(data){

            data.assetList.forEach(element =>{

                if(element.RootAssetId === element.Id && element.RecordType.DeveloperName === 'Plant'){
                    this.plantsList = !this.plantsList?[]:this.plantsList;
                    this.plantsList.push(element)
                }else{
                    this.equipmentList = !this.equipmentList?[]:this.equipmentList;
                    this.equipmentList.push(element);
                }
    
            });

            this.toolsDetails = data.contactAssetList;

            this.error = undefined;

            this.loadUI();

        }else if (error) {
            this.error = error;
        }
    }

    loadUI(){

        let url = window.location.href;

        if(url.indexOf('?') !== -1){

            let urlBrk = url.substring(url.indexOf('?')+1,url.length);

            let params = urlBrk.split('&');

            params.forEach( ele =>{

                let paramVal = ele.split('=');

                if(paramVal[0] === 'selectedPlantId'){

                    this.selectedPlantId = paramVal[1];

                }else if(paramVal[0] === 'selectedEquipmentId'){
                   this.selectedEquipmentId = paramVal[1];
                }else if(paramVal[0] === 'selectedTool'){
                    this.selectedTool = paramVal[1];
                }
            });

            this.updateLabels();
        }
    }

    updateLabels(){

        if(this.selectedEquipmentId !== ''){

            let equipment = this.equipmentList.find(ele => {

                return ele.Id === this.selectedEquipmentId;
    
            });
    
            this.selectedEquipment = equipment !== undefined?equipment.Name:'Select Equipment';

        }

        if(this.selectedPlantId !== ''){
            let plant = this.plantsList.find(ele => {

                return ele.Id === this.selectedPlantId;

            });

            this.selectedPlant = plant !== undefined?plant.Name:'Select Plant';
        }

        this.filteringEquipments();
        this.filterToolsList();
    }

    filteringEquipments(){
        if(this.selectedPlantId !== ''){
            this.filteredEquipmentList = this.equipmentList.filter(ele => {
                return ele.RootAssetId === this.selectedPlantId;
            });
        }
    }

    filterToolsList(){
        let tools = [];
        this.displayToolsList = [];

        if(this.selectedPlantId !== ''){

            let plantTools = this.toolsDetails.filter(ele => {

                return ele.AssetId__c === this.selectedPlantId;

            });

            if(Array.isArray(plantTools) && (plantTools.length > 0) && plantTools[0].AssignedApplications__c !== '' && plantTools[0].AssignedApplications__c !== null){
                (plantTools[0].AssignedApplications__c).split(';').forEach(ele =>{
                    tools.push(ele);
                })

            }

        }

        if(this.selectedEquipmentId !== ''){

            let equipTools = this.toolsDetails.filter(ele => {

                return ele.AssetId__c === this.selectedEquipmentId;

            });

            if(Array.isArray(equipTools) && (equipTools.length > 0) && equipTools[0].AssignedApplications__c !== '' && equipTools[0].AssignedApplications__c !== null){

                (equipTools[0].AssignedApplications__c).split(';').forEach(ele =>{
                    tools.push(ele);
                })

            }

        }

        this.displayToolsList = [...new Set(tools)];
        this.selectedTool = this.selectedTool !== 'Select Tool'?(this.displayToolsList.indexOf(this.selectedTool)!==-1?this.selectedTool:'Select Tool'):'Select Tool';

        /*this.filteredToolList = tools.filter(function (element, index, arrayRef) { 
            return arrayRef.indexOf(element) === index; 
        });*/
       
    }

    showHidePopup(event){

        if(event.currentTarget.dataset.type === 'plant'){
            this.showHideEquipPopup = false;
            this.showHideToolPopup = false;
            this.showHidePlantPopup = !this.showHidePlantPopup;
        }else if(event.currentTarget.dataset.type === 'equipment'){
            this.showHidePlantPopup = false;
            this.showHideToolPopup = false;
            this.showHideEquipPopup = !this.showHideEquipPopup;
        }else{
            this.showHideEquipPopup = false;
            this.showHidePlantPopup = false;
            this.showHideToolPopup = !this.showHideToolPopup;
        }
        

       /* this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "myplant"
            },
            state : {
                c__show: 'yes'
            }
        });*/
    }

    hidingOnBlur(){
        this.showHidePlantPopup = this.showHidePlantPopup?false:false;
        this.showHideEquipPopup = this.showHideEquipPopup?false:false;
        this.showHideToolPopup =  this.showHideToolPopup?false:false;
    }

    handleSelect(event){

        let url = window.location.href;
        let mainUrl = url.substring(0,url.indexOf('?'));
        let type = event.currentTarget.dataset.type;
        let finalParams = '';


        /*if(url.indexOf('?') !== -1){

            let urlBrk = url.substring(url.indexOf('?')+1,url.length);
        
            let params = urlBrk.split('&');
            
            params.forEach( ele =>{

                let paramVal = ele.split('=');

                if(paramVal[0] === 'selectedPlantId' && type === 'plant'){

                    paramVal[1] = event.currentTarget.dataset.val;

                }else if(paramVal[0] === 'selectedEquipmentId' && type === 'equipment'){
                    paramVal[1] = event.currentTarget.dataset.val;

                }

                if(paramVal[0] === 'selectedEquipmentId' && type === 'plant'){

                    this.selectedEquipmentId = '';
                    this.selectedEquipment = 'Select Equipment';
                
                }else{

                    if(finalParams === ''){
                        finalParams = paramVal[0] + '='+paramVal[1];
                    }else{
                        finalParams =finalParams+'&'+paramVal[0] + '='+paramVal[1];
                    }
                }

            });


            if(type === 'plant' && urlBrk.indexOf('selectedPlantId') === -1){
                finalParams = finalParams + (finalParams !== ''? '&selectedPlantId='+event.currentTarget.dataset.val:
                                  'selectedPlantId='+event.currentTarget.dataset.val) ;
            }
            if(type === 'equipment' && urlBrk.indexOf('selectedEquipmentId') === -1){
                finalParams = finalParams + (finalParams !== ''? '&selectedEquipmentId='+event.currentTarget.dataset.val:
                                  '?selectedEquipmentId='+event.currentTarget.dataset.val) ;
            }
            
        }else{

            finalParams = ((type === 'plant')? 'selectedPlantId=':'selectedEquipmentId=')+event.currentTarget.dataset.val;
        
        }*/

        if( type ==='plant'){
            this.selectedPlantId = event.currentTarget.dataset.val;
            this.selectedPlant = event.currentTarget.dataset.label;

            this.selectedEquipmentId = '';
            this.selectedEquipment = 'Select Equipment';
            this.selectedTool = 'Select Tool';
            this.displayToolsList = [];

            this.filteringEquipments();
            this.filterToolsList();

        }else if(type === 'equipment'){
            this.selectedEquipmentId = event.currentTarget.dataset.val;
            this.selectedEquipment = event.currentTarget.dataset.label;
            this.displayToolsList = [];
            this.filterToolsList();
        }else{
            this.selectedTool = event.currentTarget.dataset.val;
        }


       // window.location.href = mainUrl+'?'+finalParams;

       if(type !== 'tool'){
         fireEvent(this,'PlantAsset',{'plant':this.selectedPlantId,'equipment':this.selectedEquipmentId});
       }else{

        let params = '';

         if(this.selectedPlantId !== ''){
            params +=  'selectedPlantId='+this.selectedPlantId;
         }
         if(this.selectedEquipmentId !== ''){
            params +=  '&selectedEquipmentId='+this.selectedEquipmentId;
         }

         if(this.selectedTool !== 'Select Tool'){
            params +=  '&selectedTool='+this.selectedTool;
         }
         

         window.location.href = mainUrl+'?'+ params;

       }
        
    }

    displayError(error){

        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading contact',
                message : message,
                variant: 'error',
            }),
        );

    }

}