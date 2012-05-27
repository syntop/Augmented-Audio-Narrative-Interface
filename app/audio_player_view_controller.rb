class AudioPlayerViewController < UIViewController
  def loadView
    initOSC()
    
    self.view = UIView.alloc.initWithFrame(UIScreen.mainScreen.applicationFrame)
    self.view.backgroundColor = UIColor.blackColor
    
    initButtons()
    initAudioPlayer()
    initTimeDisplay()
  end
  
  def initOSC
    manager = OSCManager.alloc.init
    manager.setDelegate(self)
    @osc = manager.createNewOutputToAddress('10.0.1.7', atPort:12000)
  end
  
  def initAudioPlayer
    path = NSBundle.mainBundle.pathForResource('2006_BeagleDiary_DarwinOnline_1', ofType:'mp3')
    url = NSURL.fileURLWithPath(path)
    error_ptr = Pointer.new(:id)
    @player = AVAudioPlayer.alloc.initWithContentsOfURL(url, error:error_ptr)
    unless @player
      raise "Can't open sound file: #{error_ptr[0].description}"
    end
    
    @audio_session = AVAudioSession.sharedInstance
    err_ptr = Pointer.new(:id)
    @audio_session.setCategory(AVAudioSessionCategoryPlayback, error:err_ptr)
    
    @player.prepareToPlay()
  end
  
  def initButtons
    @play_button = UIButton.buttonWithType(UIButtonTypeCustom)
    @play_button.setImage(UIImage.imageNamed('button-play.png'), forState:UIControlStateNormal)
    @play_button.setImage(UIImage.imageNamed('button-pause.png'), forState:UIControlStateSelected)
    @play_button.addTarget(self, action:'playButtonTapped', forControlEvents:UIControlEventTouchUpInside)
    @play_button.frame = [[0, view.frame.size.width - 68], [68,68]]
    view.addSubview(@play_button)
  end
  
  def initTimeDisplay
    @time_display = UILabel.alloc.initWithFrame([[view.frame.size.height - 200, view.frame.size.width - 40], [180, 20]])
    @time_display.backgroundColor = UIColor.clearColor
    @time_display.textColor = UIColor.whiteColor
    @time_display.textAlignment = UITextAlignmentRight
    view.addSubview(@time_display)
  end
  
  def updateTimeDisplay
    current_min = (@player.currentTime/60).floor
    current_sec = (@player.currentTime%60).floor
    duration_min = (@player.duration/60).floor
    duration_sec = (@player.duration%60).floor
    @time_display.text = sprintf("%02d:%02d / %02d:%02d", current_min, current_sec, duration_min, duration_sec)
  end
  
  def playButtonTapped
    if @play_button.selected?
      @player.pause()
      if @timer
        @timer.invalidate()
      end
    else
      @player.play()
      @timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector:'updateTimeDisplay', userInfo:nil, repeats:true)
    end
    @play_button.selected = !@play_button.selected?
    err_ptr = Pointer.new(:id)
    @audio_session.setActive(@play_button.selected?, error:err_ptr)
  end
  
  def shouldAutorotateToInterfaceOrientation(orientation)
    return [UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight].include?(orientation)
  end
end