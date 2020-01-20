import { LightningElement, track, wire } from 'lwc';
import fetchAssetDetails from '@salesforce/apex/DisplayHierarchy_Cont.getAssetHierarchyDetailsCEP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cssfile from '@salesforce/resourceUrl/UpdatedSLDS';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Cep_myPlantsInfo extends LightningElement {

    @track plantsList;
    @track error;
    @track icon;
    @track hidePlants = true;
    @track updatedCss;
    @track showHideTree;
    @track selectedItem;
    @track size;
    @track mainPageSize;

    connectedCallback(){
        loadStyle(this,cssfile);
    }

    @wire(fetchAssetDetails, {recordId:'0011l000009dWYdAAM'})
    fetchAssetDetails({data,error}){
        if(data){
            this.error = undefined;

            let treeList = [];
            let lookup = {};
    
            //The below code can be updated with different attribute i.e. based on the details we would like to
            //See on the screen. In this code we are just framing the structure of attributes for all the assets fetched
            //from the SOQL
            data.forEach(function(obj) {
                lookup[obj.Id] = {
                                         'name' : obj.Id,
                                         'label': obj.Name,
                                         'expanded': false,
                                         'items' : [],
                                         'href':'',
                                         'metatext': 'Testing Data'                                         
                                    };
            });
    
            //In the below code we are creating the tree structure based on the parentId Mapping
            //Which will be looped to display the details in the Tree Structure
            data.forEach(function(obj) {
                if (obj.ParentId !== '' && obj.ParentId !== null && obj.ParentId !== undefined) {
                    lookup[obj.ParentId]['items'].push(
                        lookup[obj.Id]
                    );
                } else {
                    treeList.push(lookup[obj.Id]);
                }
            });

            this.plantsList = treeList;

            this.expandAndCollapse();

        }else if (error) {
            this.error = error;
            this.plantsList = undefined;

                const evt = new ShowToastEvent({
                    title:'Error',
                    message: this.error.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
        
        }
    }

    expandAndCollapse(){

        this.hidePlants = !this.hidePlants;

        this.icon = this.hidePlants?'utility:richtextindent':'utility:richtextoutdent';

        this.updatedCss = this.hidePlants?'slds-text-align_center slds-m-top_large slds-p-top_medium':'slds-text-align_right slds-m-top_large slds-m-bottom_large slds-p-right_medium slds-p-top_large';

        this.showHideTree = this.hidePlants?'slds-hide':'slds-p-around_small';
        this.size = this.hidePlants?'1':'3';
        this.mainPageSize = this.hidePlants?'10':'7';

    }

    handleSelect(event) {
        //set the name of selected tree item
        this.selectedItem = event.detail.name;
    }


}