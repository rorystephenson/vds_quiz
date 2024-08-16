if(void 0===window.Persistence){var e="github.com/SimonLammer/anki-persistence/",t="_default";if(window.Persistence_sessionStorage=function(){var n=!1;try{"object"==typeof window.sessionStorage&&(n=!0,this.clear=function(){for(var t=0;t<sessionStorage.length;t++){var n=sessionStorage.key(t);0==n.indexOf(e)&&(sessionStorage.removeItem(n),t--)}},this.setItem=function(n,i){null==i&&(i=n,n=t),sessionStorage.setItem(e+n,JSON.stringify(i))},this.getItem=function(n){return null==n&&(n=t),JSON.parse(sessionStorage.getItem(e+n))},this.removeItem=function(n){null==n&&(n=t),sessionStorage.removeItem(e+n)},this.getAllKeys=function(){for(var t=[],n=Object.keys(sessionStorage),i=0;i<n.length;i++){var s=n[i];0==s.indexOf(e)&&t.push(s.substring(e.length,s.length))}return t.sort()})}catch(e){}this.isAvailable=function(){return n}},window.Persistence_windowKey=function(n){var i=window[n],s=!1;"object"==typeof i&&(s=!0,this.clear=function(){i[e]={}},this.setItem=function(n,s){null==s&&(s=n,n=t),i[e][n]=s},this.getItem=function(n){return null==n&&(n=t),null==i[e][n]?null:i[e][n]},this.removeItem=function(n){null==n&&(n=t),delete i[e][n]},this.getAllKeys=function(){return Object.keys(i[e])},null==i[e]&&this.clear()),this.isAvailable=function(){return s}},window.Persistence=new Persistence_sessionStorage,Persistence.isAvailable()||(window.Persistence=new Persistence_windowKey("py")),!Persistence.isAvailable()){var i=window.location.toString().indexOf("title"),n=window.location.toString().indexOf("main",i);i>0&&n>0&&n-i<10&&(window.Persistence=new Persistence_windowKey("qt"))}}var Debug=document.getElementById("multiple-choice-debug");function init(){let e=document.getElementsByClassName("multiple-choice-button");if(!Persistence.isAvailable())return void log("Persistence not available: multiple choices will not work.");for(let t=0;t<e.length;t++){let n=e[t];null!==Persistence.getItem(t)?n.innerHTML=Persistence.getItem(t):(log("Button number "+t+" was not persisted."),n.innerHTML="none")}let t=getCorrectButtonIndex(),n=getChoosenButtonIndex();-1!==t&&(-1!==n&&n!==t&&styleButton(e[n],"multiple-choice-wrong"),styleButton(e[t],"multiple-choice-correct"))}function log(e){null!==Debug&&null!=Debug&&(Debug.innerHTML+=e+"<br>")}function styleButton(e,t){e.classList.add(t)}function getCorrectButtonIndex(){let e=Persistence.getItem("correctButton");return null===e&&(log("Correct answer was not set."),e=-1),e}function getChoosenButtonIndex(){let e=Persistence.getItem("choosenButton");return null===e&&(e=-1),e}init(),Persistence.clear();
