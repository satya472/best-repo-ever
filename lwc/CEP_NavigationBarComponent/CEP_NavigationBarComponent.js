import { LightningElement, track } from 'lwc';

export default class CEP_NavigationBarComponent extends LightningElement {

    @track menuItems = [
        {
           Name: 'Home',
           hasSubMenu: false,
           subMenuList: []
        },
        {
            Name: 'Legacy Portals',
            hasSubMenu: true,
            subMenuList: ['CEP 1.0','Omnivise Portfolio','PSCD Portal']
        },
        { 
           Name: 'My Plant',
           hasSubMenu: false,
           subMenuList: ['CEP1.0','Omnivise Portfolio','PSCD Portal']

        },
        {
            Name: 'Outage Planner',
            hasSubMenu: false,
            subMenuList: []
         },
         {
            Name: 'Bulletins and Reports',
            hasSubMenu: false,
            subMenuList: []
         },
        { 
            Name: 'Support',
            hasSubMenu: false,
            subMenuList: ['CEP1.0','Omnivise Portfolio','PSCD Portal']
         }
        
    ];

    handleMenuSelect(event){

        let elementsLst = this.template.querySelectorAll("a");
        for (let i = 0; i < elementsLst.length; i++) {
            if(event.target.innerText === elementsLst[i].innerText){
                elementsLst[i].childNodes[0].className = "active";
            }else{
                elementsLst[i].childNodes[0].className = "";
            }
            
        }
    }

    addResponsive(){
        let elementsLst = this.template.querySelectorAll(".topnav");
        if(elementsLst[0].className === 'topnav'){
            elementsLst[0].className += " responsive";
        }else{
            elementsLst[0].className = "topnav";
        }
        
    }

}