class AudioPlayerViewController < UIViewController
  def loadView
    initOSC()
    
    self.view = UIView.alloc.initWithFrame(UIScreen.mainScreen.applicationFrame)
    self.view.backgroundColor = UIColor.redColor
  end
  
  def initOSC
    manager = OSCManager.alloc.init
    manager.setDelegate(self)
    @osc = manager.createNewOutputToAddress('10.0.1.7', atPort:12000)
  end
  
  def map_scroll_view
    @map_scroll_view ||= begin
      map_scroll_view = TiledScrollView.alloc.initWithFrame([[0,0],[768,768]])
      map_scroll_view.delegate = self
      map_scroll_view.clipsToBounds = true
      map_scroll_view.scrollEnabled = true
      map_scroll_view.pagingEnabled = false
      map_scroll_view.maximumZoomScale = 2.0
      map_scroll_view.minimumZoomScale = 0.5
      map_scroll_view.bounces = true
      map_scroll_view.userInteractionEnabled = true
      map_scroll_view.setContentSize([map_image_view.frame.size.width, map_image_view.frame.size.height])
      map_scroll_view.backgroundColor = UIColor.whiteColor
      map_scroll_view.setZoomScale(1.0)
      map_scroll_view.addSubview(map_image_view)
      map_scroll_view
    end
  end
  
  def shouldAutorotateToInterfaceOrientation(orientation)
    return [UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight].include?(orientation)
  end
end