
% set figure background to white
% s = settings;
% if ~verLessThan('matlab', '9.15') && ...
%         ~(s.matlab.appearance.figure.GraphicsTheme.ActiveValue=="auto" && s.matlab.appearance.CurrentTheme.ActiveValue=="Dark") && ...
%         s.matlab.appearance.figure.GraphicsTheme.ActiveValue~="Dark"
%     % set(groot,'defaultUIControlBackgroundColor','w');
%     % set(groot,'defaultUipanelBackgroundColor','w');
%     % set(groot,'defaultFigureColor','w');

    set(groot,'defaultAxesXColorMode','manual');
    set(groot,'defaultAxesYColorMode','manual');
    set(groot,'defaultAxesZColorMode','manual');
    set(groot,'defaultAxesXColor',0.5*[1,1,1]);
    set(groot,'defaultAxesYColor',0.5*[1,1,1]);
    set(groot,'defaultAxesZColor',0.5*[1,1,1]);

    set(groot,'defaultLegendEdgeColor',1*ones(1,3));
    set(groot,'defaultLegendBox','off');

% end

% set line width
defaultLinewidth = 1.5;
set(groot,'defaultLineLineWidth',       defaultLinewidth)
set(groot,'defaultRectangleLineWidth',  defaultLinewidth)
if ~verLessThan('matlab', '8.4')
    set(groot,'defaultScatterLineWidth',1);
    set(groot,'defaultBarLineWidth',    1);
end
clear defaultLinewidth;


set(groot,'defaultAxesTickDirMode','manual');
set(groot,'defaultAxesTickDir','none');

% line color
% if ~isMATLABReleaseOlderThan("R2023b")
%     set(groot,"DefaultAxesColorOrder",orderedcolors("gem12"));
% end

% % see getcolormap in gramm
% % opts.map = 'lch';
% % opts.chroma_range=[30 90];
% % opts.hue_range=[25 385];
% % opts.lightness=65;
% % opts.chroma=75;
% % opts.legend='separate_gray';
% % cmap=get_colormap(12,1,opts)
% cmap = ... 
% [1.0000    0.3673    0.4132
% 0.9687    0.4812    0.1716
% 0.7777    0.5915         0
% 0.5270    0.6690         0
% 0.0282    0.7141    0.2944
% 0    0.7352    0.5645
% 0    0.7375    0.8344
% 0    0.7175    1.0000
% 0    0.6637    1.0000
% 0.5171    0.5678    1.0000
% 0.8903    0.4407    0.9246
% 1.0000    0.3412    0.6744];
% set(groot,"DefaultAxesColorOrder",cmap);

set(groot,'defaultHistogramEdgeColor','auto');

set(groot,'defaultAxesXGrid','on', 'defaultAxesYGrid','on', 'defaultAxesZGrid','on');

% if all(get(groot,'ScreenSize') == [1 1 1920 1080])
%     set(groot, 'defaultFigurePosition', [680  558  680  420]);
% end

if ~verLessThan('matlab', '9.10')
    method = 'padded';
    set(groot,'defaultAxesXLimitMethod',method);
    set(groot,'defaultAxesYLimitMethod',method);
    set(groot,'defaultAxesZLimitMethod',method);
    clear method;
end

% if ~verLessThan('matlab', '9.15')
%     [~] = feature('DiagnosticReportStackFrameDecorationCharacter', '_');
% end

% % set font name, size, etc...
% defaultFontName = 'Times New Roman';
% set(groot,'defaultAxesFontName', defaultFontName)
% set(groot,'defaultTextFontName', defaultFontName)
% set(groot, 'defaultAxesFontWeight', 'normal', ...
%            'defaultAxesFontSize', 12, ...
%            'defaultAxesFontAngle', 'normal', ... % Not sure the difference here
%            'defaultAxesFontWeight', 'normal', ... % Not sure the difference here
%            'defaultAxesTitleFontWeight', 'normal', ...
%            'defaultAxesTitleFontSizeMultiplier', 1) ;
% clear defaultFontName;

% set axes grid
% set(groot,'defaultAxesGridLineStyle',':')
% set(groot,'defaultAxesGridAlpha',1)

% suppress warning: Image is too big to fit on screen; displaying at xx%
warning off images:initSize:adjustingMag
clear s;