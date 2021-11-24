import { useEffect, useRef, useState, withHooks } from 'mithril-hooks'
import { ProjectDetails, UserDetails } from '../../entities'
import { Loader } from '../../shared/components/loader'
import PopNotification from '../../c/pop-notification'
import userVM from '../../vms/user-vm'
import './coming-soon-landing-page-bookmark-card.scss'
import h from '../../h'
import { getCurrentUserCached } from '../../shared/services/user/get-current-user-cached'
import { isLoggedIn } from '../../shared/services/user/is-logged-in'
import m from 'mithril'
import { removeRemind } from './controllers/removeRemind'
import { remind } from './controllers/remind'
import './coming-soon-landing-page-bookmark-card-remind-button.css'

export type ComingSoonLandingPageBookmarkCardRemindButtonProps = {
    isProjectCard?: boolean
    project: ProjectDetails
    isFollowing: boolean
}

export const ComingSoonLandingPageBookmarkCardRemindButton = withHooks<ComingSoonLandingPageBookmarkCardRemindButtonProps>(_ComingSoonLandingPageBookmarkCardRemindButton)

function _ComingSoonLandingPageBookmarkCardRemindButton(props: ComingSoonLandingPageBookmarkCardRemindButtonProps) {

    const { isProjectCard = false, project, isFollowing } = props
    const popupTimeout = useRef<NodeJS.Timeout>()
    const [isLoading, setIsLoading] = useState(false)
    const [currentUserBookmarked, setCurrentUserBookmarked] = useState(isFollowing)

    // Pop notification properties
    const timeDisplayingPopup = 5000
    const [displayPopNotification, setDisplayPopNotification] = useState(false)
    const [popNotificationMessage, setPopNotificationMessage] = useState('')
    const [isPopNotificationError, setIsPopNotificationError] = useState(false)

    function redirectToLogin() {
        if (!isLoggedIn(getCurrentUserCached())) {
            h.storeAction('reminder', project.project_id)
            h.navigateToDevise(`?redirect_to=${location.pathname}?remindMe=true`)
            return true
        }

        return false
    }

    const remindMe = async (event: Event) => {
        event.preventDefault()
        if (redirectToLogin()) return
        toggleRemindMeProject()
    }

    const removeRemindMe = async (event: Event) => {
        event.preventDefault()
        toggleRemindMeProject()
    }

    useEffect(() => {
        setCurrentUserBookmarked(project.in_reminder)
        toggleRemindAndRemoveParamOptionToPerformIt()
    }, [project.in_reminder])

    function toggleRemindAndRemoveParamOptionToPerformIt() {
        const params = m.parseQueryString(location.search)
        if (params.remindMe && !project.in_reminder) {
            toggleRemindMeProject()
        }
        delete params['remindMe']
        m.route.set(location.pathname + location.hash, params)
    }

    async function toggleRemindMeProject() {
        const {
            toggle,
            successMessage,
            errorMessage,
        } = configRemindRequest(project)

        try {
            setIsLoading(true)
            await toggle()
            setCurrentUserBookmarked(!project.in_reminder)
            await displayPopNotificationMessage({ message: successMessage })
        } catch (error) {
            await displayPopNotificationMessage({ message: errorMessage, isError: true })
        } finally {
            setIsLoading(false)
        }
    }

    async function displayPopNotificationMessage({message, isError = false} : {message: string, isError?: boolean}) {
        setPopNotificationMessage(message)
        setIsPopNotificationError(isError)
        setDisplayPopNotification(!displayPopNotification)
        if (popupTimeout.current) clearTimeout(popupTimeout.current)
        setTimeout(() => setDisplayPopNotification(true))
        popupTimeout.current = setTimeout(() => setDisplayPopNotification(false), timeDisplayingPopup)
    }

    return (
        <div class="back-project-btn-div">
            {
                displayPopNotification &&
                <PopNotification
                    message={popNotificationMessage}
                    error={isPopNotificationError} />
            }
            <div class={isProjectCard ? "save-project-card-wrapper" : "back-project--btn-row"}>
                {
                    isLoading ?
                        <Loader />
                        :
                        currentUserBookmarked ?
                            <button onclick={removeRemindMe} class={`btn ${isProjectCard ? 'btn-medium btn-terciary w-button' : 'btn-large btn-secondary'}`}>
                                <span class="fa fa-bookmark text-success"></span>&nbsp;
                                Projeto Salvo
                            </button>
                            :
                            <button onclick={remindMe} class={`btn ${isProjectCard ? 'btn-medium btn-dark w-button' : 'btn-large'}`}>
                                <span class="fa fa-bookmark-o"></span>&nbsp;
                                Avise-me do lançamento!
                            </button>
                }
                {
                    ((project.reminder_count > 10 || project.is_owner_or_admin) && !isProjectCard) &&
                    <div class="fontsize-smaller fontcolor-secondary fontweight-semibold u-text-center u-margintop-10">
                        {project.reminder_count} seguidores
                    </div>
                }
            </div>
        </div>
    )
}

const configRemindRequest = (project: ProjectDetails) => ({
    async toggle() {
        if (project.in_reminder) {
            await removeRemind(project)
        } else {
            await remind(project)
        }
    },
    successMessage: project.in_reminder ?
        'Ok, Removemos o lembrete por e-mail de quando a campanha for ao ar!' :
        'Você irá receber um email quando este projeto for publicado!',
    errorMessage: project.in_reminder ?
        'Error ao remover lembrete.' :
        'Error ao salvar lembrete.'
})
