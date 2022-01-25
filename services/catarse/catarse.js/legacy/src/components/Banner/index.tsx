import m from 'mithril'
import { useEffect, useState, withHooks } from 'mithril-hooks'
import './styles.css';
import '../../main.css';

export type BannerProps = {
    type?: 'default' | 'success' | 'critical' | 'informational' | 'warning';
    content?: string;
    title?: string;
    closeButton?: boolean;
}

export const Banner = withHooks<BannerProps>(_Banner)

export function _Banner({ type = 'default', content, title = '', closeButton = false }: BannerProps) {

    const [isLoading, setIsLoading] = useState(false);
    const [isVisible, setVisible] = useState(true);

    if (isVisible) {
        return (
            <div className={`banner banner-${type}`}>

                <div className='content'>
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M10 20C15.514 20 20 15.514 20 10C20 4.486 15.514 -4.82049e-07 10 0C4.486 4.82049e-07 -4.82049e-07 4.486 0 10C4.82049e-07 15.514 4.486 20 10 20ZM11 14C11 14.5523 10.5523 15 10 15C9.44771 15 9 14.5523 9 14V10C9 9.44772 9.44771 9 10 9C10.5523 9 11 9.44772 11 10V14ZM10 5C9.44771 5 9 5.44771 9 6C9 6.55229 9.44771 7 10 7C10.5523 7 11 6.55229 11 6C11 5.44771 10.5523 5 10 5Z" class="alert-icon"/>
                    </svg>

                    <div className="content-text">
                        {title && (
                            <p className='content-text-heading'>{title}</p>
                        )}
                        <p className='content-text-body'>{content}</p>
                    </div>
                </div>

                {closeButton && (
                    <div className='close-button' onClick={() => setVisible(false)}>
                        x
                    </div>
                )}
            </div>
        );
    };
};

