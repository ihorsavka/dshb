

import Foundation


public struct BatteryWidget: Widget {
    
    private var meters = [Meter]()
    var title : WidgetTitle
    var win   : Window
    
    init(win: Window) {
        // win.width not in use right now
        
        self.win = win
        
        let titleCoords = Window(size: (length: win.size.length, width: 1), pos: (x:win.pos.x, y:win.pos.y))
        title = WidgetTitle(title: "Battery", winCoords: titleCoords, colour: COLOR_PAIR(5))        

        
        meters.append(Meter(name: "Charge", winCoords : Window(size: (length: win.size.length, width: 1), pos: (x:win.pos.x, y:win.pos.y + 1)), max: 100, unit: Meter.Unit.Percentage))
        meters.append(Meter(name: "Capacity", winCoords : Window(size: (length: win.size.length, width: 1), pos: (x:win.pos.x, y:win.pos.y + 2)), max: battery.designCapacity(), unit: Meter.Unit.None))
        meters.append(Meter(name: "Cycles", winCoords : Window(size: (length: win.size.length, width: 1), pos: (x:win.pos.x, y:win.pos.y + 3)), max: battery.designCycleCount(), unit: Meter.Unit.None))
        meters.append(Meter(name: "Health", winCoords : Window(size: (length: win.size.length, width: 1), pos: (x:win.pos.x, y:win.pos.y + 4)), max: 100, unit: Meter.Unit.Percentage))
    }
    
    
    mutating func draw() {
        meters[0].draw(Int(battery.charge()))
        meters[1].draw(battery.currentCapacity())
        meters[2].draw(battery.cycleCount())
        meters[3].draw(Int(battery.health()))
    }
    
    
    mutating func resize(newCoords: Window) -> Int32 {
        self.win = newCoords
        
        title.resize(win)
        
        var y_pos = win.pos.y + 1 // Becuase of title
        
        for var i = 0; i < meters.count; ++i {
            meters[i].resize(Window(size: (length: widgetLength, width: 1), pos: (x: win.pos.x, y: y_pos)))
            y_pos++
        }
        
        return y_pos
    }
}