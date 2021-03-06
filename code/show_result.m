function [fig] = show_result(p0_orig,kgrid,p0_recon,kgrid_recon,cart_sensor_mask,binary_sensor_mask)
    fig = figure;
    pause(0.0001);
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);
    pause(0.0001);

    subplot(1,2,1);
    imagesc(cart2grid(kgrid, cart_sensor_mask)+p0_orig, [0, 1]);
    ylabel('x-position');
    xlabel('y-position');
    title('Original image');
    axis image;
    colormap('parula');
    caxis([0,0.5]);
    colorbar;
    
    subplot(1,2,2);
    imagesc(binary_sensor_mask+p0_recon, [0, 1]);
    ylabel('x-position');
    xlabel('y-position');
    title('Reconstructed image');
    axis image;
    colormap('parula');
    caxis([0,0.5]);
    colorbar;
    
    return
end
