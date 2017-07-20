public class MICanvasLifeCyclehandler implements Canvas.CanvasLifecycleHandler {
    public String CANVAS_ERROR = 'An error has occurred, please try again. If you continue to experience an issue, please contact Radian Customer Care at 877-Radian1 (877-723-4261) or by using the Live Help option above.';
    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        //excluded.add(Canvas.ContextTypeEnum.ORGANIZATION);
        return excluded;
    }
    
    public void onRender(Canvas.RenderContext renderContext) {
        String logString = '';
        Boolean isError = false;
        Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();
        Canvas.ApplicationContext app = renderContext.getApplicationContext();
            logString += 'Canvas APP URL - ' + app.getCanvasUrl() + '\nDisplay Location - ' + env.getDisplayLocation() + '\nLocation URL - ' + EncodingUtil.urlDecode(env.getLocationUrl(),'UTF-8') + '\nSub Location - ' + env.getSublocation() + '\nParameters - ' + env.getParametersAsJSON();
    system.debug('logString:-'+logString);
    }
    }