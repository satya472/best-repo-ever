import {LightningElement, track, wire, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {loadStyle,loadScript} from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import BOOTSTRAP from '@salesforce/resourceUrl/b4';
import FONTS from '@salesforce/resourceUrl/fonts';
import IMAGES from '@salesforce/resourceUrl/images';
import userId from '@salesforce/user/Id';
import getNavigationItems from '@salesforce/apex/CEPLightningNavCont.getNavigationItems';
import getNotificationDetails from '@salesforce/apex/CEPAssetPlantToolsCont.getNotificationDetails';

export default class Header extends NavigationMixin(LightningElement) {

  @track logo = IMAGES + '/SiemensLogo.gif';
  @track profile = IMAGES + '/T.png';
  @track navigationArr;
  @track notificationList;
  @track notificationCount;
  @track userName;
  userId = userId;
  @track tostNotification

  constructor() {
    super();
    this.template.addEventListener('click', (evt) => {
    })
  }
  

  @wire(getNotificationDetails) notificationListDetails({error, data }) {
    if (data) {
      this.notificationList = [];
      data.forEach(ele => {
        if (!ele.Notified_Contacts__r) {
          this.notificationList.push({
            'Id':ele.Id,
            'Name':ele.Name,
            'class': ele.NotificationImportance__c == 'Urgent' ? 'fas fa-exclamation-circle' : 'fas fa-exclamation-triangle'
          });
        }
      });
      this.notificationCount = this.notificationList.length;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.notificationList = undefined;
    }    
  }

  @wire(getRecord, { recordId: userId, fields: ['User.FirstName','User.LastName']})wireuser({error,data}){
    if (data) {
      this.userName = data.fields.FirstName.value+' '+data.fields.LastName.value;
    } else if (error) {
      this.error = error;
      this.notificationList = undefined;
    }
  }

  connectedCallback() {

    loadStyle(this, BOOTSTRAP + '/css/bootstrap.min.css');
    loadStyle(this, BOOTSTRAP + '/css/header.css');
    loadStyle(this, FONTS + '/css/all.css');
    loadScript(this, BOOTSTRAP + '/js/jquery.min.js');
    loadScript(this, BOOTSTRAP + '/js/popper.min.js');
    loadScript(this, BOOTSTRAP + '/js/bootstrap.min.js')
      .then(() => {
        console.log('file loaded.......')
      })
      .catch(error => {
        console.error({
          message: 'Error occured on bootstrap loading',
          error
        });
      })

    getNavigationItems().then(data => {
      this.prepareNavigationData(data);
    });

  }

  prepareNavigationData(data) {
    this.navigationArr = [];
    data.forEach(node => {
      // No parentId means top level
      if (!node.ParentId) return this.navigationArr.push(node);
      // Insert node as child of parent in flat array
      const parentIndex = data.findIndex(el => el.Id === node.ParentId);
      if (!data[parentIndex].children) {
        return data[parentIndex].children = [node];
      }
      data[parentIndex].children.push(node);
    });
  }


  showNotification(event) {
    event.preventDefault();
    let style = this.template.querySelector('div.notification').style.display;
    if (style == "none" || style == "") {
      this.template.querySelector('div.notification').classList.add('show');
      this.template.querySelector('div.notification').style.display = 'block';
    } else {
      this.template.querySelector('div.notification').style.display = 'none';
      this.template.querySelector('div.notification').classList.remove('show');
    }

  }


  displayUserProfile(event) {
    event.preventDefault();
    let style = this.template.querySelector('div.profile-setting').style.display;
    if (style == "none" || style == "") {
      this.template.querySelector('div.profile-setting').style.display = 'block';
    } else {
      this.template.querySelector('div.profile-setting').style.display = 'none';
    }
  }

  displayMenuItems(event) {
    event.preventDefault();
    let style = this.template.querySelector('div.collapse').style.display;
    if (style == "none" || style == "") {
      this.template.querySelector('div.collapse').style.display = 'block';
    } else {
      this.template.querySelector('div.collapse').style.display = 'none';
    }
  }

  displaySubMenuItems(event) {
    event.preventDefault();
    let style = this.template.querySelector('div.sub-menu').style.display;
    if (style == "none" || style == "") {
      this.template.querySelector('div.sub-menu').style.display = 'block';
    } else {
      this.template.querySelector('div.sub-menu').style.display = 'none';
    }
  }


  navigateToRecordViewPage(event) {
    event.preventDefault();
    let Object = event.currentTarget.getAttribute("data-id");
    // View a custom object record.
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.userId,
        objectApiName: Object, // objectApiName is optional
        actionName: 'view'
      }
    });
  }

  navigateToPage(event) {
    event.preventDefault();
    let target = event.currentTarget.getAttribute("data-target");
    let type = event.currentTarget.getAttribute("data-type");
    if (type == "InternalLink") {
      target = target.replace('/', '');
    }
    window.location.href = target;
  }
}