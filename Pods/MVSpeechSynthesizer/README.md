MVSpeechSynthesizer
===================

Effective way to use an AVSpeechSynthesizer

 <h2>Why MVSpeechSynthesizer?<h2> 
 
<p>1. Simple way to integrate the AVSpeechsynthesizer into your app.</p>
<p>2. Instead of delgate method it provides block methods.</p>
<p>3. Apart from simple usage it can auto detect the language of given string and read.</p>
<p>4. It can higlight currently reading word.</p>
<p>5. It also throw currently reading word</p> 
<p>6. It can auto scroll the page if once reached bottom of the text box.</p>
<p>7. It can read all languages which is supported by AVSpeechSynthesizer</p>
<p>8. It can list all supported langauages and their country name</p>


  <h2>MVSpeechSynthesizer</h2>
  <div>MVSpeechSynthesizer in action</div>
  <div><b>MVSpeechSynthesizer in action</b> - It shows highlight the text.
  <br>

   ![Custom Keyboard](https://raw.githubusercontent.com/vimalmurugan89/MVSpeechSynthesizer/master/speechsynthesizer.gif)

   <br>

<h2>Who need this?<h2>

<p>1. Whoever developing kids reading books</p>
<p>2. Whoever wants to read their EULA or privacy policy to their user</p>
<p>3. Whoever developing apps with voice navigation</p>
<p>4. Whoever wants to integrate reading functionality to thier app</p>

<h2>Pod Installation</h2>

<p>Add the following to your CocoaPods Podfile</p>

    pod 'MVSpeechSynthesizer'

<h2>Apps Using this control</h2>

  
  
  <br>

   ![Custom Keyboard](http://a2.mzstatic.com/us/r30/Purple/v4/c4/d9/bb/c4d9bbbb-c97d-cac2-b8d0-78146cb1eb57/icon_256.png)

   <br>
<a href="https://itunes.apple.com/us/app/secure-notes-lock-your-important/id836702121?mt=8">Secure Notes - Lock your important notes</a>
<p>Let me know if any other using this control(Just drop a mail)</p>

<h2>Future enhancement<h2>

   <p>1. To read any webpage with highlighted text</p>
   <p>2. Gives different voices(female and male)</p>

<h2>How to use this?</h2>
   <p>For changing the language use <b>speechLanguage</b> object</p>
   <p>For passing the read string use <b>speechString</b> object </p>
   <p>For getting supported langauges call <b>supportedLanguages</b> function</p>
   <p>for changing the string just copy some other string and paste on text box.</p>
   <p>For choosing language just press language button you will navigate to the list of languages page their you can choose language</p>
   <p>For enable and disable the highlight use <b>isHighlight</b> object</p>
   <p>For changing speech voice <b>uRate</b> and <b>pitchMultiplier</b> objects</p>
    
   <p>Just initialize the <b>MVSpeechsynthesizer</b> class and do the following steps,</p>
   
        MVSpeechSynthesizer *mvSpeech=[MVSpeechSynthesizer sharedSyntheSize];//Initialize the class
        mvSpeech.higlightColor=[UIColor yellowColor];//Higlght backgroundcolor
        mvSpeech.isTextHiglight=YES;//If you want to highlight set yes, othgerwise set no.
        mvSpeech.speechString=//Pass string which is need to read.
       mvSpeech.inputView=_helpTextView;//Pass the input view which carries the string.
       [mvSpeech startRead];//Initialize the read function.
       mvSpeech.speechFinishBlock=^(AVSpeechSynthesizer *synthesizer, AVSpeechUtterance *utterence){
         //It will call when read action finished.
       };
       
    
<p>Let me know if any issues?</p>






 
