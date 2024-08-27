"use strict";(self.webpackChunkwebsite=self.webpackChunkwebsite||[]).push([[2415],{1156:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>p,frontMatter:()=>i,metadata:()=>s,toc:()=>c});var a=t(5893),r=t(1151);const i={id:"genapp",sidebar_position:6,title:"GenApp",custom_edit_url:null},o=void 0,s={id:"Prepare/genapp",title:"GenApp",description:"WCA4Z Data Generator",source:"@site/docs/1-Prepare/5-GenApp.mdx",sourceDirName:"1-Prepare",slug:"/Prepare/genapp",permalink:"/solution-watsonx-wca4z/Prepare/genapp",draft:!1,unlisted:!1,editUrl:null,tags:[],version:"current",sidebarPosition:6,frontMatter:{id:"genapp",sidebar_position:6,title:"GenApp",custom_edit_url:null},sidebar:"tutorialSidebar",previous:{title:"Cloud Object Storage",permalink:"/solution-watsonx-wca4z/Prepare/cloud_object_storage"},next:{title:"Architect",permalink:"/solution-watsonx-wca4z/Prepare/architect"}},l={},c=[{value:"WCA4Z Data Generator",id:"wca4z-data-generator",level:2},{value:"Retrieving the installation file",id:"retrieving-the-installation-file",level:3},{value:"Configuration and Build of GenApp project",id:"configuration-and-build-of-genapp-project",level:2},{value:"Create a new Project",id:"create-a-new-project",level:3}];function d(e){const n={a:"a",code:"code",h2:"h2",h3:"h3",img:"img",li:"li",p:"p",pre:"pre",ul:"ul",...(0,r.a)(),...e.components};return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(n.h2,{id:"wca4z-data-generator",children:"WCA4Z Data Generator"}),"\n",(0,a.jsx)(n.p,{children:"The WCA4Z Data Generator is for generating data. It lives on the ADDI host."}),"\n",(0,a.jsx)(n.h3,{id:"retrieving-the-installation-file",children:"Retrieving the installation file"}),"\n",(0,a.jsx)(n.p,{children:"If you have already downloaded RA version 1.1.x, open up WinSCP on the ADDI host."}),"\n",(0,a.jsxs)(n.p,{children:["Create a login to the RA host in WinSCP\n",(0,a.jsx)(n.img,{src:"https://media.github.ibm.com/user/20330/files/f2cced1c-8810-4c16-9999-58922143b628",alt:"CleanShot 2024-03-05 at 14 14 41"})]}),"\n",(0,a.jsx)(n.p,{children:"Save the login and connect."}),"\n",(0,a.jsxs)(n.p,{children:["If you've already followed the directions ",(0,a.jsx)(n.a,{href:"Refactor",children:"here"})," for the config and install of RA, you should have the extracted folder sitting in your home directory:"]}),"\n",(0,a.jsx)(n.p,{children:(0,a.jsx)(n.img,{src:"https://media.github.ibm.com/user/20330/files/9c73f00c-6fcd-4601-9ae4-28bf5561a3ae",alt:"CleanShot 2024-03-05 at 14 19 32"})}),"\n",(0,a.jsx)(n.p,{children:"Drag the WCA4Z-Data-Generator zip to your home documents folder on the ADDI host."}),"\n",(0,a.jsx)(n.p,{children:(0,a.jsx)(n.img,{src:"https://media.github.ibm.com/user/20330/files/d9ad5ab6-c96a-48b2-b346-db579b969e37",alt:"CleanShot 2024-03-05 at 14 24 37"})}),"\n",(0,a.jsxs)(n.p,{children:["Unzip the WCA4Z-Data-Generator zip file into ",(0,a.jsx)(n.code,{children:"C:\\Program Files\\IBM Application Discovery and Delivery Intelligence"})]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-powershell",children:"Expand-Archive -LiteralPath 'C:\\Users\\Administrator\\Documents\\WCA4Z-Data-Generator-1.1.2.zip' -DestinationPath 'C:\\Program Files\\IBM Application Discovery and Delivery Intelligence'\n"})}),"\n",(0,a.jsx)(n.h2,{id:"configuration-and-build-of-genapp-project",children:"Configuration and Build of GenApp project"}),"\n",(0,a.jsxs)(n.p,{children:["Download the CCS GenApp code zip to the ADDI host from ",(0,a.jsx)(n.a,{href:"https://github.com/cicsdev/cics-genapp/archive/refs/heads/main.zip",children:"here"})]}),"\n",(0,a.jsxs)(n.p,{children:["Extract ",(0,a.jsx)(n.code,{children:"C:\\Users\\Administrator\\Downloads\\cics-genapp-main.zip"}),"."]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-powershell",children:"Expand-Archive -LiteralPath 'C:\\Users\\Administrator\\Downloads\\cics-genapp-main.zip' -DestinationPath 'D:\\'\n"})}),"\n",(0,a.jsx)(n.h3,{id:"create-a-new-project",children:"Create a new Project"}),"\n",(0,a.jsx)(n.p,{children:"Let's create an INI project file in D:\\"}),"\n",(0,a.jsx)(n.p,{children:"Values should be as follows in our example."}),"\n",(0,a.jsxs)(n.ul,{children:["\n",(0,a.jsxs)(n.li,{children:["DBServerName - this should be ",(0,a.jsx)(n.code,{children:"BLUDB"}),". It is the db2 cloud database entry we created ",(0,a.jsx)(n.a,{href:"/Prepare/cloud_databases#installingconfiguring-db2-client",children:"here"})]}),"\n",(0,a.jsxs)(n.li,{children:["FQDN + port - should be retrieved from the returned JSON from ",(0,a.jsx)(n.a,{href:"/Prepare/cloud_databases#creating-the-service-credentials",children:"here"}),". Our example cloud db2 url is ",(0,a.jsx)(n.code,{children:"dbd5d8b8-61c3-49dc-9213-79a4104c27f6.c8l9ggsd0kmvoig3l8kg.databases.appdomain.cloud:31106"})]}),"\n"]}),"\n",(0,a.jsx)(n.p,{children:(0,a.jsx)(n.code,{children:"project.ini"})}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-tsx",children:'[ADNewProj]\nProjectName = "GenAppSD"\nPath = "C:\\IBM AD\\Mainframe Projects\\GenAppSD"\nEnvironment = "zOS"\nProjectLanguages = "DT Cobol,Assembler,Cobol,Natural,PL1,Ads"\nDBTypes = "Datacom,IDMS,Adabas,Relational,IMS/DB"\nMapTypes = "Natural (LNM),CICS (BMS), IMS TM (MFS),ADS Map"\nProjectDBType = "DB2_LUW"\nCCSEnvironment = "Default"\nDBServerName = "BLUDB [dbd5d8b8-61c3-49dc-9213-79a4104c27f6.c8l9ggsd0kmvoig3l8kg.databases.appdomain.cloud:31106]"\nDBName = "BLUDB"\nAttachToDB = "Y"\nEnableCross = "N"\n'})}),"\n",(0,a.jsxs)(n.p,{children:["Make sure the directory for ",(0,a.jsx)(n.code,{children:"Path"})," exists. Create the folder."]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-powershell",children:"mkdir 'C:\\IBM AD\\Mainframe Projects\\GenAppSD'\n"})}),"\n",(0,a.jsx)(n.p,{children:"Run the project creation command:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-powershell",children:'cd "C:\\Program Files\\IBM Application Discovery and Delivery Intelligence\\IBM Application Discovery Build Client\\Bin\\Release"\n.\\IBMApplicationDiscoveryBuildClient.exe /np "D:\\project.ini"\n\n'})})]})}function p(e={}){const{wrapper:n}={...(0,r.a)(),...e.components};return n?(0,a.jsx)(n,{...e,children:(0,a.jsx)(d,{...e})}):d(e)}},1151:(e,n,t)=>{t.d(n,{Z:()=>s,a:()=>o});var a=t(7294);const r={},i=a.createContext(r);function o(e){const n=a.useContext(i);return a.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function s(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:o(e.components),a.createElement(i.Provider,{value:n},e.children)}}}]);