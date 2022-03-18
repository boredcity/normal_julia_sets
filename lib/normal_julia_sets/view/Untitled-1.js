/*
HTML5 Mandelbrot set & Julia sets by ZoltÃ¡n BacskÃ³ (http://falcosoft.hu) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.

Warning! In order this program to work on local machine file: protocol under Google Chrome/Opera Next you have to set --allow-file-access-from-files
*/

"use strict";

window.onload = function() {
	setTimeout(function() { Mandel.load(640, 480); }, 100);
};

var Mandel = (function(ids) {
		var palette = bwpal;

		var canvas;
		var ct2d;
		var surfacewidth;
		var surfaceheight;
		var initwidth;
		var initheight;
		var backimg;
		var animpal;
		var animoffset = 0;

		var iscanvastypedarr;
		var iscpule;

		var bailoutvalue = 4.0;
		var maxiter = 150;

		var startx = -2.4;
		var starty = 1.2;
		var extx = 3.2;
		var exty = 2.4;

		var re = 0.0;
		var im = 0.0;
		var prevstartx = startx;
		var prevstarty = starty;
		var prevextx = extx;
		var prevexty = exty;
		var prevre = re;
		var previm = im;
		var julia = false;

		var lp1;
		var lp2;
		var gred = 6;
		var ggreen = 12;
		var gblue = 18;
		var range = 1;

		var mousedown = false;
		var mouseb;
		var mousebx;
		var mouseby;
		var ttouches;

		var mthread;
		var maxthreads = 8;
		var actthread = 1;
		var workers = [];
		var timeout = 0;

		var gi = 0;
		var start = 0;

		function resetvalues(preset) {
			animoffset = 0;
            startx = -1.553033696714109880;
            extx = 1.528650709352576100 - startx;
            starty = 1.094045464862574510;
            exty = starty + 1.102749622025527560;
            re = -0.777306122448979592;
            im = 0.118040816326530612;
            julia = true;
            bailoutvalue = 4.0;
            maxiter = 1000;
            ids.iteration.value = maxiter;
            ids.bailout.value = bailoutvalue;
            palette = 2;
            ids.bw.checked = true;

			maincalc();
		}


		function iter(a, b, x, y, ba, mi) {
			var n = 0;
			var x2 = x * x;
			var y2 = y * y;

			do {
				y = 2 * x * y + b;
				x = x2 - y2 + a;
				x2 = x * x;
				y2 = y * y;
				n++;
			}
			while (((x2 + y2) < ba) && (n < mi));

			return n;
		}


		function calcrowsmt() {
			gi = 0;
			var i;
			var worker;
			for (i = 0; i < maxthreads; i++) {
				worker = workers[i];
				if (worker.idle) {
					var b = (starty - (gi * lp2));
					var a = startx;
					worker.idle = false;
					worker.postMessage({
							gi: gi,
							a: a,
							b: b,
							re: re,
							im: im,
							lp1: lp1,
							maxiter: maxiter,
							bailoutvalue: bailoutvalue,
							surfacewidth: surfacewidth,
							julia: julia
						});

					gi++;
				}
			}
		}


		function msghandler(worker, data) {
			var n;
			var offset = 0;
			var mandelimg = ct2d.createImageData(surfacewidth, 1);
			var pixelarray = mandelimg.data;
			var values = data.values;
			var index;
			var pixelarray32;
			var j;

			if (iscanvastypedarr && iscpule) {
				pixelarray32 = new Uint32Array(mandelimg.data.buffer);

				for (j = 0; j < surfacewidth; j++) {
					n = values[j];

					if (n >= maxiter) {
						animpal[(data.gi * surfacewidth) + j] = 0;
						pixelarray32[offset++] = 255 << 24;

					} else {
						animpal[(data.gi * surfacewidth) + j] = n;

						if (palette === 0) {
							index = (n + animoffset) & 65535;
							if (index === 0) index = 1;
							pixelarray32[offset++] = ((255 << 24) |
								(((index * gblue * range) & 255) << 16) |
								(((index * ggreen * range) & 255) << 8) |
								(index * gred * range) & 255);

						} else {
							index = (n + animoffset) & 255;
							if (index === 0) index = 1;
							pixelarray32[offset++] = ((255 << 24) |
								(palette[index][2] << 16) |
								(palette[index][1] << 8) |
								palette[index][0]);
						}
					}
				}
			}
			else if (iscanvastypedarr) {
				pixelarray32 = new Uint32Array(mandelimg.data.buffer);

				for (j = 0; j < surfacewidth; j++) {
					n = values[j];

					if (n >= maxiter) {
						animpal[(data.gi * surfacewidth) + j] = 0;
						pixelarray32[offset++] = 255;

					} else {

						animpal[(data.gi * surfacewidth) + j] = n;

						if (palette === 0) {
							index = (n + animoffset) & 65535;
							if (index === 0) index = 1;
							pixelarray32[offset++] = (255 |
								(((index * gblue * range) & 255) << 8) |
								(((index * ggreen * range) & 255) << 16) |
								(((index * gred * range) & 255) << 24));

						} else {
							index = (n + animoffset) & 255;
							if (index === 0) index = 1;
							pixelarray32[offset++] = (255 |
								(palette[index][2] << 8) |
								(palette[index][1] << 16) |
								(palette[index][0] << 24));
						}
					}
				}
			}
			else
			for (j = 0; j < surfacewidth; j++) {
				n = values[j];

				if (n >= maxiter) {
					animpal[(data.gi * surfacewidth) + j] = 0;

					pixelarray[offset++] = 0;
					pixelarray[offset++] = 0;
					pixelarray[offset++] = 0;
					pixelarray[offset++] = 255;
				} else {

					animpal[(data.gi * surfacewidth) + j] = n;

					if (palette === 0) {
						index = (n + animoffset) & 65535;
						if (index === 0) index = 1;
						pixelarray[offset++] = (index * gred * range) & 255;
						pixelarray[offset++] = (index * ggreen * range) & 255;
						pixelarray[offset++] = (index * gblue * range) & 255;
						pixelarray[offset++] = 255;
					} else {
						index = (n + animoffset) & 255;
						if (index === 0) index = 1;
						pixelarray[offset++] = palette[index][0];
						pixelarray[offset++] = palette[index][1];
						pixelarray[offset++] = palette[index][2];
						pixelarray[offset++] = 255;
					}
				}
			}

			ct2d.putImageData(mandelimg, 0, data.gi);
			if (gi < surfaceheight) {
				var b = (starty - (gi * lp2));
				var a = startx;
				worker.idle = false;
				worker.postMessage({
						gi: gi,
						a: a,
						b: b,
						re: re,
						im: im,
						lp1: lp1,
						maxiter: maxiter,
						bailoutvalue: bailoutvalue,
						surfacewidth: surfacewidth,
						julia: julia
					});
				gi++;
			} else {
				worker.idle = true;
				if (actthread === maxthreads) {
					var elapsed = new Date().getTime() - start;
					actthread = 1;
				} else actthread++;
			}
		}


		function calcrows() {

			var n = 0;
			var offset = 0;
			var mandelimg = ct2d.createImageData(surfacewidth, 1);
			var pixelarray = mandelimg.data;
			var index;
			var pixelarray32;
			var j;

			var b = (starty - (gi * lp2));
			var a = startx;

			if (iscanvastypedarr && iscpule) {
				pixelarray32 = new Uint32Array(mandelimg.data.buffer);

				for (j = 0; j < surfacewidth; j++) {
					a = a + lp1;
					if (!julia)
					n = iter(a, b, re, im, bailoutvalue, maxiter);
					else
					n = iter(re, im, a, b, bailoutvalue, maxiter);


					if (n >= maxiter) {
						animpal[(gi * surfacewidth) + j] = 0;
						pixelarray32[offset++] = 255 << 24;

					} else {

						animpal[(gi * surfacewidth) + j] = n;

						if (palette === 0) {
							index = (n + animoffset) & 65535;
							if (index === 0) index = 1;
							pixelarray32[offset++] = ((255 << 24) |
								(((index * gblue * range) & 255) << 16) |
								(((index * ggreen * range) & 255) << 8) |
								(index * gred * range) & 255);
						} else {
							index = (n + animoffset) & 255;
							if (index === 0) index = 1;
							pixelarray32[offset++] = ((255 << 24) |
								(palette[index][2] << 16) |
								(palette[index][1] << 8) |
								palette[index][0]);
						}
					}
				}
			}
			else if (iscanvastypedarr) {
				pixelarray32 = new Uint32Array(mandelimg.data.buffer);

				for (j = 0; j < surfacewidth; j++) {
					a = a + lp1;
					if (!julia)
					n = iter(a, b, re, im, bailoutvalue, maxiter);
					else
					n = iter(re, im, a, b, bailoutvalue, maxiter);


					if (n >= maxiter) {
						animpal[(gi * surfacewidth) + j] = 0;
						pixelarray32[offset++] = 255;

					} else {

						animpal[(gi * surfacewidth) + j] = n;

						if (palette === 0) {
							index = (n + animoffset) & 65535;
							if (index === 0) index = 1;
							pixelarray32[offset++] = (255 |
								(((index * gblue * range) & 255) << 8) |
								(((index * ggreen * range) & 255) << 16) |
								(((index * gred * range) & 255) << 24));
						} else {
							index = (n + animoffset) & 255;
							if (index === 0) index = 1;
							pixelarray32[offset++] = (255 |
								(palette[index][2] << 8) |
								(palette[index][1] << 16) |
								(palette[index][0] << 24));
						}
					}
				}
			}
			else
			for (j = 0; j < surfacewidth; j++) {
				a = a + lp1;
				if (!julia)
				n = iter(a, b, re, im, bailoutvalue, maxiter);
				else
				n = iter(re, im, a, b, bailoutvalue, maxiter);


				if (n >= maxiter) {
					animpal[(gi * surfacewidth) + j] = 0;

					pixelarray[offset++] = 0;
					pixelarray[offset++] = 0;
					pixelarray[offset++] = 0;
					pixelarray[offset++] = 255;

				} else {

					animpal[(gi * surfacewidth) + j] = n;

					if (palette === 0) {
						index = (n + animoffset) & 65535;
						if (index === 0) index = 1;
						pixelarray[offset++] = (index * gred * range) & 255;
						pixelarray[offset++] = (index * ggreen * range) & 255;
						pixelarray[offset++] = (index * gblue * range) & 255;
						pixelarray[offset++] = 255;
					} else {
						index = (n + animoffset) & 255;
						if (index === 0) index = 1;
						pixelarray[offset++] = palette[index][0];
						pixelarray[offset++] = palette[index][1];
						pixelarray[offset++] = palette[index][2];
						pixelarray[offset++] = 255;
					}
				}
			}

			ct2d.putImageData(mandelimg, 0, gi);

			if (gi < surfaceheight - 1) {
				gi++;
				if (gi % 24 !== 0)
				calcrows();
				else
				setTimeout(calcrows, 0);
			} else {
				var elapsed = new Date().getTime() - start;
			}

		}


		function maincalc() {
			ids.panim.checked = false;
			start = new Date().getTime();
			gi = 0;
			lp1 = extx / surfacewidth;
			lp2 = exty / surfaceheight;
			//ct2d.fillRect(0,0,surfacewidth,surfaceheight);
			if (!mthread.checked) calcrows();
			else calcrowsmt();
		}


		function paletteanim(redrawonly) {
			if (!redrawonly && !ids.panim.checked) return;

			var pixelarray = backimg.data;
			var offset = 0;
			var index = 0;
			var indexoffset = 0;
			var i = surfacewidth * surfaceheight;
			var pixelarray32;

			if (!redrawonly) animoffset = (animoffset + 1) & 0xFFFFFFFF;

			if (iscanvastypedarr && iscpule) {
				pixelarray32 = new Uint32Array(backimg.data.buffer);
				while (indexoffset < i) {

					index = animpal[indexoffset];

					if (palette === 0) {
						if (index !== 0) {
							index = (index + animoffset) & 65535;
							if (index === 0) index = 1;
						}
						pixelarray32[indexoffset] = ((255 << 24) |
							(((index * gblue * range) & 255) << 16) |
							(((index * ggreen * range) & 255) << 8) |
							((index * gred * range) & 255));
					}
					else {
						if (index !== 0) {
							index = (index + animoffset) & 255;
							if (index === 0) index = 1;
						}
						pixelarray32[indexoffset] = ((255 << 24) |
							(palette[index][2] << 16) |
							(palette[index][1] << 8) |
							palette[index][0]);
					}

					indexoffset++;
				}
			}
			else if (iscanvastypedarr) {
				pixelarray32 = new Uint32Array(backimg.data.buffer);
				while (indexoffset < i) {

					index = animpal[indexoffset];

					if (palette === 0) {
						if (index !== 0) {
							index = (index + animoffset) & 65535;
							if (index === 0) index = 1;
						}
						pixelarray32[indexoffset] = (255 |
							(((index * gblue * range) & 255) << 8) |
							(((index * ggreen * range) & 255) << 16) |
							(((index * gred * range) & 255) << 24));
					}
					else {
						if (index !== 0) {
							index = (index + animoffset) & 255;
							if (index === 0) index = 1;
						}
						pixelarray32[indexoffset] = (255 |
							(palette[index][2] << 8) |
							(palette[index][1] << 16) |
							(palette[index][0] << 24));
					}

					indexoffset++;
				}
			}
			else {
				while (indexoffset < i) {

					index = animpal[indexoffset];

					if (palette === 0) {
						if (index !== 0) {
							index = (index + animoffset) & 65535;
							if (index === 0) index = 1;
						}
						pixelarray[offset++] = (index * gred * range) & 255;
						pixelarray[offset++] = (index * ggreen * range) & 255;
						pixelarray[offset++] = (index * gblue * range) & 255;
						pixelarray[offset++] = 255;
					}
					else {
						if (index !== 0) {
							index = (index + animoffset) & 255;
							if (index === 0) index = 1;
						}
						pixelarray[offset++] = palette[index][0];
						pixelarray[offset++] = palette[index][1];
						pixelarray[offset++] = palette[index][2];
						pixelarray[offset++] = 255;
					}

					indexoffset++;
				}
			}

			ct2d.putImageData(backimg, 0, 0);

			if (!redrawonly && ids.panim.checked)
			setTimeout(function() { paletteanim(false); }, 24);

		}

		function palanimclick() {
			var checked = ids.panim.checked;
			if (checked) paletteanim(false);
		}


		function getmousepos(canvas, evt) {
			var rect = canvas.getBoundingClientRect();
			var multx = (surfacewidth / initwidth);
			var multy = (surfaceheight / initheight);
			return {
				x: ((evt.clientX - rect.left) * multx) | 0,
				y: ((evt.clientY - rect.top) * multy) | 0
			};
		}

		function onmousedown(e) {
			mousedown = true;
			mouseb = e.button;
			var mousepos = getmousepos(canvas, e);

			mousebx = Math.round(mousepos.x);
			mouseby = Math.round(mousepos.y);

			backimg = ct2d.getImageData(0, 0, surfacewidth, surfaceheight);
		}

		function onmousemove(e) {
			var mousepos = getmousepos(canvas, e);
			var currx = Math.round(mousepos.x);
			var curry = Math.round(mousepos.y);

			if (mousedown && mouseb === 0) {

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);


				ct2d.putImageData(backimg, 0, 0);
				ct2d.strokeStyle = "rgb(255,255,255)";
				ct2d.strokeRect(mousebx, mouseby, currx - mousebx, curry - mouseby);
			}
			var xre = startx + (currx * lp1);
			var yim = starty - (curry * lp2);
		}

		function onmouseup(e) {
			if (mousedown && e.button === 0 && !e.ctrlKey) {
				var mousepos = getmousepos(canvas, e);

				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);

				if ((Math.abs(currx - mousebx) > 3) && (Math.abs(curry - mouseby) > 3)) {

					extx = (startx + (currx * lp1)) - (startx + (mousebx * lp1));
					exty = (starty - (mouseby * lp2)) - (starty - (curry * lp2));
					startx = startx + (mousebx * lp1);
					starty = starty - (mouseby * lp2);

					maincalc();
				}
				//julia switch
				else {

					julia = !julia;

					if (julia) {
						prevstartx = startx;
						prevstarty = starty;
						prevextx = extx;
						prevexty = exty;
						prevre = re;
						previm = im;
						re = startx + (currx * lp1);
						im = starty - (curry * lp2);
						startx = -2;
						starty = 1.5;
						extx = 4;
						exty = 3;
					} else {
						startx = prevstartx;
						starty = prevstarty;
						extx = prevextx;
						exty = prevexty;
						re = prevre;
						im = previm;
					}

					maincalc();
				}
				//
			} else if (mousedown && e.button === 0 && e.ctrlKey) {
				var mousepos = getmousepos(canvas, e);

				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);

				if ((Math.abs(currx - mousebx) > 3) && (Math.abs(curry - mouseby) > 3)) {

					var visszx = oszt(surfacewidth, (currx - mousebx));
					var visszy = oszt(surfaceheight, (curry - mouseby));
					extx = ((startx + extx) + ((surfacewidth - currx) * lp1 * visszx)) - (startx - (mousebx * lp1 * visszx));
					exty = (starty + (mouseby * lp2 * visszy)) - ((starty - exty) - ((surfaceheight - curry) * lp2 * visszy));
					startx = startx - (mousebx * lp1 * visszx);
					starty = starty + (mouseby * lp2 * visszy);

					maincalc();
				}
			} else if (mousedown && e.button === 2) {
				var mousepos = getmousepos(canvas, e);

				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				if ((Math.abs(currx - mousebx) > 3) || (Math.abs(curry - mouseby) > 3)) {
					startx = startx + ((mousebx - currx) * lp1);
					starty = starty - ((mouseby - curry) * lp2);

					maincalc();
				}
			}
			mousedown = false;
		}


		function wheel(event) {
			var delta = 0;
			if (!event) event = window.event;
			if (event.wheelDelta) {
				delta = event.wheelDelta / 120;
			} else if (event.detail) {
				delta = -event.detail / 3;
			}
			if (delta)
			wheelhandle(delta);
			if (event.preventDefault)
			event.preventDefault();
			event.returnValue = false;
		}


		function wheelhandle(delta) {
			if (delta < 0) {
				var visszx = oszt(surfacewidth, (surfacewidth - 8));
				var visszy = oszt(surfaceheight, (surfaceheight - (8 * surfaceheight / surfacewidth)));
				extx = extx + (8 * lp1 * visszx);
				exty = exty + ((8 * surfaceheight / surfacewidth) * lp2 * visszy);
				startx = startx - (4 * lp1 * visszx);
				starty = starty + ((4 * surfaceheight / surfacewidth) * lp2 * visszy);
			} else {
				extx = extx - (8 * lp1);
				exty = exty - ((8 * surfaceheight / surfacewidth) * lp2);
				startx = startx + (4 * lp1);
				starty = starty - ((4 * surfaceheight / surfacewidth) * lp2);
			}
			if (mthread.checked) {
				clearTimeout(timeout);
				timeout = setTimeout(maincalc, 250);
			} else maincalc();
		}

		//touch

		function ontouchstart ( e )
		{
			e.preventDefault();
			var touch = e.targetTouches[0];
			ttouches = e.targetTouches.length;
			mousedown = true;

			var mousepos = getmousepos(canvas, touch);

			mousebx = Math.round(mousepos.x);
			mouseby = Math.round(mousepos.y);

			backimg = ct2d.getImageData(0, 0, surfacewidth, surfaceheight);
		}

		function ontouchmove ( e )
		{
			e.preventDefault();
			var touch = e.targetTouches[0];

			var mousepos = getmousepos(canvas, touch);
			var currx = Math.round(mousepos.x);
			var curry = Math.round(mousepos.y);

			if (mousedown && ttouches === 1)
			{

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);


				ct2d.putImageData(backimg, 0, 0);
				ct2d.strokeStyle = "rgb(255,255,255)";
				ct2d.strokeRect(mousebx, mouseby, currx - mousebx, curry - mouseby);
			}
		}

		function ontouchend ( e )
		{
			e.preventDefault();
			var touch = e.changedTouches[0];
			if (mousedown && ttouches === 1 && !e.ctrlKey)
			{
				var mousepos = getmousepos(canvas, touch);
				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);

				if ((Math.abs(currx - mousebx) > 3) && (Math.abs(curry - mouseby) > 3))
				{
					extx = (startx + (currx * lp1)) - (startx + (mousebx * lp1));
					exty = (starty - (mouseby * lp2)) - (starty - (curry * lp2)) ;
					startx = startx + (mousebx * lp1);
					starty = starty - (mouseby * lp2);

					maincalc();

				}

				else
				{

					julia=!julia;

					if (julia)
					{
						prevstartx = startx;
						prevstarty = starty;
						prevextx = extx;
						prevexty = exty;
						prevre = re;
						previm = im;
						re = startx + (currx * lp1);
						im = starty - (curry * lp2);
						startx = -2;
						starty = 1.5;
						extx = 4;
						exty = 3;
					}
					else
					{
						startx = prevstartx;
						starty = prevstarty;
						extx = prevextx;
						exty = prevexty;
						re = prevre;
						im = previm;
					}

					maincalc();
				}
			}
			else if (mousedown && ttouches === 1 && e.ctrlKey)
			{
				var mousepos = getmousepos(canvas, touch);

				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				curry = mouseby + (booltoint(curry > mouseby) * 2 - 1) * Math.round(surfaceheight * Math.abs(currx - mousebx) / surfacewidth);

				if ((Math.abs(currx - mousebx) > 3) && (Math.abs(curry - mouseby) > 3))
				{

					var visszx = oszt(surfacewidth, (currx - mousebx));
					var visszy = oszt(surfaceheight, (curry - mouseby));
					extx = ((startx + extx) + ((surfacewidth - currx) * lp1 * visszx)) - (startx - (mousebx * lp1 * visszx));
					exty = (starty + (mouseby * lp2 * visszy)) - ((starty - exty) - ((surfaceheight - curry) * lp2 * visszy));
					startx = startx - (mousebx * lp1 * visszx);
					starty = starty + (mouseby * lp2 * visszy);

					maincalc();
				}
			}
			else if (mousedown && ttouches > 1)
			{
				var mousepos = getmousepos(canvas, touch);

				var currx = Math.round(mousepos.x);
				var curry = Math.round(mousepos.y);

				if ((Math.abs(currx - mousebx) > 3) || (Math.abs(curry - mouseby) > 3))
				{
					startx = startx +((mousebx-currx)*lp1);
					starty = starty -((mouseby-curry)*lp2);

					maincalc();
				}
			}
			mousedown = false;
		}

		//

		function radiovalue() {
			var i;
			var radios = ids.radioclasses;
			for (i = 0; i < radios.length; i++) {
				if (radios[i].type === 'radio' && radios[i].checked)
				return radios[i].value;
			}
		}


		function redrawpresets() {
			var tmpstr;
			var i;

			if (window.localStorage && localStorage.length > 0) {
				tmpstr =  '<ul class="presets">';

				for (i = 0; i < localStorage.length; i++) {
					var lskey =  localStorage.key(i);
					tmpstr += '<li><a href="javascript:Mandel.resetvalues(\'' +  lskey + '\');">' +  lskey +'</a>';
					tmpstr += '<div title="Remove preset" class=\'removebtn\' onclick=\'localStorage.removeItem("'+lskey+'"); Mandel.redrawpresets();\'>&nbsp;&times;&nbsp;&nbsp;&nbsp;</div></li>';

				}
				tmpstr += '</ul>';
			}
			else  tmpstr = "";

			ids.custpresets_div.innerHTML = tmpstr;
		}

		function initialize(canvasElement, w, h) {
			var i;
			var inputs;
			var ilength;
			var worker;
			var panim = ids.panim;
			panim.checked = false;

			//if (window.navigator.hardwareConcurrency)
			//maxthreads = window.navigator.hardwareConcurrency * 2;

			ids.aa2x.checked = false;

			mthread = ids.mthread;
			if (!window.Worker) {
				mthread.checked = false;
				mthread.disabled = true;
			} else {
				try {
					mthread.checked = true;
					for (i = 0; i < maxthreads; i++) {
						worker = new Worker("worker.js");
						worker.onmessage = function(event) {
							msghandler(event.target, event.data);
						};
						worker.idle = true;
						workers.push(worker);
					}
				}
				catch(error) {
					mthread.checked = false;
					mthread.disabled = true;
					alert(error.message);
				}
			}

			surfacewidth = w;
			surfaceheight = h;
			canvas = (canvasElement);

			if (canvas.addEventListener)
			canvas.addEventListener('DOMMouseScroll', wheel, false);

			canvas.onmousewheel = wheel;

			canvas.width = w;
			canvas.height = h;
			ct2d = canvas.getContext("2d");

			backimg = ct2d.createImageData(surfacewidth, surfaceheight);

			if (window.Uint32Array)
			animpal = new Uint32Array(surfacewidth * surfaceheight);
			else
			animpal = [];

			iscanvastypedarr = (Object.prototype.toString.call(backimg.data) == "[object Uint8ClampedArray]");
			
			if (iscanvastypedarr) {
				var pixelarray32 = new Uint32Array(backimg.data.buffer);
				pixelarray32[0] = 0x0a0b0c0d;
				iscpule = (backimg.data[0] === 0x0d);
			}

			canvas.onmousedown = onmousedown;
			canvas.onmousemove = onmousemove;
			canvas.onmouseup = onmouseup;

			canvas.addEventListener('touchstart', ontouchstart);
			canvas.addEventListener('touchmove', ontouchmove);
			canvas.addEventListener('touchend', ontouchend);

			ids.presetsave_btn.onclick = onpresetsave;
			ids.panim.onclick = palanimclick;
			ids.aa2x.onclick = aastatechange;
			ids.main_ok.onclick = paramschange;

			ids.bw.onclick = ids.vga.onclick;
			ids.nice.onclick = ids.vga.onclick;
			ids.proc.onclick = ids.vga.onclick;

			ids.sliderred.onchange = function() {
				ids.sliders[0].f_setValue(ids.sliderred.value);
				ids.proc.checked = true;
				var pchecked = panim.checked;
				gred = parseInt(ids.sliderred.value);
				palette = 0;
				animoffset = 0;
				if (!pchecked) paletteanim(true);
			};

			ids.slidergreen.onchange = function() {
				ids.sliders[1].f_setValue(ids.slidergreen.value);
				ids.proc.checked = true;
				var pchecked = panim.checked;
				ggreen = parseInt(ids.slidergreen.value);
				palette = 0;
				animoffset = 0;
				if (!pchecked) paletteanim(true);
			};

			ids.sliderblue.onchange = function() {
				ids.sliders[2].f_setValue(ids.sliderblue.value);
				ids.proc.checked = true;
				var pchecked = panim.checked;
				gblue = parseInt(ids.sliderblue.value);
				palette = 0;
				animoffset = 0;
				if (!pchecked) paletteanim(true);
			};

			ids.custpreset_txt.onkeypress=function(e) {
				if(e.keyCode === 13) {
					ids.presetsave_btn.click();
				}
			};

			inputs = ids.inputclass1;
			ilength = inputs.length;
			for(i = 0; i < ilength; i++) {
				inputs[i].onkeypress = function(e) {
					if(e.keyCode === 13) {
						ids.main_ok.click();
					}
				};
			}

			var tinst = ids.touchclasses;
			if ("ontouchstart" in document.documentElement)	{
				for (i = 0; i < tinst.length; i++) {
					tinst[i].style.display = "block";
				}
			}

			redrawpresets();
			resetvalues(0);
		}

		function load(w, h) {
			ids.canvas.style.width = w + "px";
			ids.canvas.style.height = h + "px";
			initwidth = w;
			initheight = h;

			initialize(ids.canvas, initwidth, initheight);
		}

		function aainit(w, h) {
			surfacewidth = w;
			surfaceheight = h;
			canvas.width = w;
			canvas.height = h;
			ct2d = canvas.getContext("2d");

			backimg = ct2d.createImageData(surfacewidth, surfaceheight);

			if (window.Uint32Array)
			animpal = new Uint32Array(surfacewidth * surfaceheight);
			else
			animpal = [];

			maincalc();
		}

		function aastatechange() {
			var checked = ids.aa2x.checked;
			if (checked)
			aainit(initwidth << 1, initheight << 1);
			else
			aainit(initwidth, initheight);
		}

		function paramschange() {
			maxiter = parseInt(ids.iteration.value);
			bailoutvalue = parseFloat(ids.bailout.value);
			gred = parseInt(ids.sliderred.value);
			ggreen = parseInt(ids.slidergreen.value);
			gblue = parseInt(ids.sliderblue.value);
			range = ids.p100.checked ? 0.01 : 1;
			palette = parseInt(radiovalue());

			ids.panim.checked = false;
			animoffset = 0;
			maincalc();
		}

		function oszt(x, y) {
			if (y === 0) return 0;
			else return x / y;
		}

		function booltoint(b) {
			return b ? 1 : 0;
		}

		function pngconvert() {
			var url = canvas.toDataURL("image/png");
			var newwin = window.open();
			newwin.document.open();
			newwin.document.write('<html><head><title>HTML5 Mandelbrot:canvas image<\/title><\/head><body><img id="cnvimg"><\/body><\/html>');
			newwin.document.close();
			var cnvimg = newwin.document.getElementById("cnvimg")	;
			cnvimg.src = url;
			//window.open(url,'canvas image');
		}

		return {
			load:load,
			resetvalues:resetvalues,
			redrawpresets:redrawpresets,
			pngconvert:pngconvert
		};

	}
	({
			rendtime : document.getElementById("rendtime"),
			divx : document.getElementById("divx"),
			divy : document.getElementById("divy"),
			sliderred : document.getElementById("sliderred"),
			slidergreen : document.getElementById("slidergreen"),
			sliderblue : document.getElementById("sliderblue"),
			iteration : document.getElementById("iteration"),
			bailout : document.getElementById("bailout"),
			p100 : document.getElementById("p100"),
			proc : document.getElementById("proc"),
			vga : document.getElementById("vga"),
			bw : document.getElementById("bw"),
			nice : document.getElementById("nice"),
			panim : document.getElementById("panim"),
			custpresets_div : document.getElementById("custpresets_div"),
			custpreset_txt : document.getElementById("custpreset_txt"),
			aa2x : document.getElementById("aa2x"),
			mthread : document.getElementById("mthread"),
			presetsave_btn : document.getElementById("presetsave_btn"),
			main_ok : document.getElementById("main_ok"),
			canvas : document.getElementById("canvas"),
			touchclasses : document.getElementsByClassName("touchdev"),
			radioclasses : document.getElementsByClassName("radiobtns"),
			inputclass1 : document.getElementsByClassName("txtinput1"),
			sliders: A_SLIDERS
		}));