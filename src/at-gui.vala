//!valac --pkg gtk+-3.0 -X -lm --pkg posix %f
//#!./% &
using Gtk;
using Cairo;
//--------------------------------------------------------
/*
圆心：鼠标1键拖动，其他键退出。
其他：鼠标1键选择定时。
*/
//--------------------------------------------------------
bool mode2;

public class Timer : Gtk.Window {
	const int size=400;
	const int MIN = size/10;
	const int MAX = size/2-size/12;

	const string B_COLOR="#4E4E4E";
	const string F_COLOR="#CCCCCC";
	const string M_COLOR="#57C575";

	int mm = 0;
	int hh = 0; bool kp = false; int scale = 60; double degree = 0;
	Gdk.RGBA cc;
//----------------------------
	public Timer() {
		if(mode2){kp=true; scale = 24;}
		title = "AT";
		decorated = false; app_paintable = true;
		set_visual(this.get_screen().get_rgba_visual());
		set_size_request(size,size);
		add_events (Gdk.EventMask.BUTTON_PRESS_MASK|Gdk.EventMask.POINTER_MOTION_MASK|
					Gdk.EventMask.KEY_PRESS_MASK|Gdk.EventMask.KEY_RELEASE_MASK);
		destroy.connect (Gtk.main_quit);
		draw.connect (on_draw);
//----------鼠标移动事件。
		motion_notify_event.connect ((e) => {
			int x; int y;
			x=(int)(e.x-size/2); y=(int)(e.y-size/2);
			int d=(int)Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
			if(d<MIN || d>MAX) return true;	//有效圆环
			degree=Math.atan2(y, x)/(Math.PI/180)+90;
			if(degree<0) degree+=360;
			queue_draw();
			return true;
		});
//----------鼠标点击事件。
		button_press_event.connect ((e) => {
			int x; int y;
			x=(int)(e.x-size/2); y=(int)(e.y-size/2);
			int d=(int)Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
			if(d>MAX) return true;	//有效圆环以外
			if(d<MIN){	//圆心之内
				if(e.button == 1){
					begin_move_drag ((int)e.button, (int)e.x_root, (int)e.y_root, e.time);
				}
				else Gtk.main_quit();
				return true;
			}
			if(e.button == 1){	//有效圆环
				if(kp){	hh=mm; if(mode2){kp=false; scale = 60; queue_draw();}; return true; }
				if(mode2){
					stdout.printf("at %d:%d\n",hh,mm);
					Posix.system("at-gui.bash %d %d".printf(hh,mm));
					} else {
					stdout.printf("at now + %d minutes\n",hh*60+mm);
					Posix.system("at-gui.bash %d".printf(hh*60+mm));
					}
	//~ echo 'export DISPLAY=:0.0 && /home/eexpss/bin/rockpng "/home/eexpss/图片/s.png"' |\at "now + 1 minutes"
				Gtk.main_quit();
			}
			return true;
		});
//----------按键事件。
		key_press_event.connect ((e) => {
			if(mode2) return true;
			if(e.keyval == Gdk.Key.Control_L || e.keyval == Gdk.Key.Control_R)
			{ kp=true; scale = 24; queue_draw(); }
			return true;
		});
		key_release_event.connect ((e) => {
			if(mode2) return true;
			if(e.keyval == Gdk.Key.Control_L || e.keyval == Gdk.Key.Control_R)
			{ kp=false; scale = 60; queue_draw(); }
			return true;
		});
	}
//---------------------
	private void align_show(Context ctx, int i, double size){
		ctx.set_font_size(size);
		string showtext="%d".printf(i);
		Cairo.TextExtents ex;
		ctx.text_extents (showtext, out ex);
		ctx.rel_move_to(-ex.width/2,ex.height/2);
		ctx.show_text(showtext);
		}
//---------------------
	private bool on_draw (Context ctx) {
		mm=(int)(degree*scale/360);

		ctx.translate(size/2, size/2);	//窗口中心为坐标原点。
		ctx.set_line_cap (Cairo.LineCap.ROUND);
		ctx.set_operator (Cairo.Operator.SOURCE);
//---------------------底色
		cc.parse(B_COLOR); ctx.set_source_rgba (cc.red, cc.green, cc.blue, 0.8);
		ctx.arc(0,0,size/2-size/20,0,2*Math.PI);
		ctx.fill();
//---------------------增加一个扇形延时显示
		ctx.save();
		cc.parse(M_COLOR); ctx.set_source_rgba (cc.red, cc.green, cc.blue, 0.6);
		ctx.rotate(-Math.PI/2);
		ctx.move_to(0,0);
		ctx.arc(0,0,size/2-size/8,0,mm*2*Math.PI/scale);	//阶段性刻度
//~ 		ctx.arc(0,0,size/2-size/8,0,degree*Math.PI/180);	//顺滑的刻度
		ctx.fill();
		ctx.restore();
//---------------------刻度
		ctx.save();
		cc.parse(F_COLOR); ctx.set_source_rgba (cc.red, cc.green, cc.blue, 1);
		for(int i=0;i<scale;i++){
//~ 			ctx.set_line_width (2*(kp?2:1));
			ctx.set_line_width (2);
			ctx.move_to(0,-MAX);
			if(! kp && i%5==0){ ctx.rel_line_to(0,15); }else{ ctx.rel_line_to(0,5); }
			if(i%(scale/4)==0){
				if(kp){ctx.rel_line_to(0,10);}
				ctx.rel_move_to(0,20);
				align_show(ctx, i, size/20);
				}
			ctx.stroke();
			ctx.rotate((360/scale)*(Math.PI/180));	//6度一个刻度
		}
		ctx.restore();
//---------------------圆心
		cc.parse(F_COLOR); ctx.set_source_rgba (cc.red, cc.green, cc.blue, 1);
		ctx.arc(0,0,MIN,0,2*Math.PI);
		ctx.fill();
//---------------------时间
		cc.parse(B_COLOR); ctx.set_source_rgba (cc.red, cc.green, cc.blue, 0.8);
		ctx.move_to(0,0);
		align_show(ctx, mm, size/12);
		return true;
	}
}
//--------------------------------------------------------
int main (string[] args) {
	Gtk.init(ref args);
// 带任意参数，使用模式2执行，强制选择并输出小时和分钟2个参数。
	if(args[1]==null) mode2=false; else mode2=true;
	var ww = new Timer(); ww.show_all();
	Gtk.main(); return 0;
}
//--------------------------------------------------------
